package main

import sdl "vendor:sdl3"

// N4NG4N packages =)
import g4n "../g4n"
import ecs "../ecs"
// ------------------

import "core:fmt"
import "core:mem"
import "core:log"

// An enum denoting what level of debugging the program should do.
// Release has no debugging info.
// Debug_Info logs debug data.
// Debug_Visual adds drawing debug info to the screen.
// Visual debugging is stuff like hitbox rectangle drawing, etc.
// Debug Slow adds an artifical delay to the g_state loop. Configurable with DEBUG_MS_WAIT
Debug_Level :: enum { Release = 0, Debug_Info, Debug_Visual, Debug_Slow}
GLOBAL_DEBUG_LEVEL :: Debug_Level.Debug_Visual
DEBUG_MS_WAIT :: 10

when GLOBAL_DEBUG_LEVEL > .Release {
	LOG_DESTINATION :: "log/debug/log.txt"
	LOWEST_LOG_LEVEL :: log.Level.Debug
} else {
	LOG_DESTINATION :: "log/log.txt"
	LOWEST_LOG_LEVEL :: log.Level.Info
}

// Entry point
main :: proc() {
	// This creates and uses a tracking allocator for the program
	// The tracking allocator acts as an in-house valgrind, kind of
	// great for debugging
	when GLOBAL_DEBUG_LEVEL > .Release {
		t_alloc := g4n.create_tracking_allocator()
		context.allocator = mem.tracking_allocator(&t_alloc)
		defer g4n.destroy_tracking_allocator(&t_alloc)
	}


	// Neat little thing that will allow program to log info to a file.
	// Good for more formal debugging that printfs, and can provide user some info on crashes
	// Used with ~ log.logf(LEVEL, STRING, ARGS)
	file_logger := g4n.create_file_logger(LOG_DESTINATION, LOWEST_LOG_LEVEL)
	context.logger = file_logger
	defer g4n.report_tracking_allocator(&t_alloc)
	defer g4n.destroy_file_logger(file_logger)
	defer log.logf(.Info, "\n\n\nGoodbye =)")
	
	//----------------------------------------------------------------------

	log.logf(.Info, "\n\n\n== INITIALIZATION ==")
	log.logf(.Debug, "Setup of context complete. Logger and Allocator Created.")
	log.logf(.Info, "Debug level = %v.", GLOBAL_DEBUG_LEVEL)
	when GLOBAL_DEBUG_LEVEL >= .Debug_Slow {
		log.logf(.Info, "Debug delay in MS = %v.", DEBUG_MS_WAIT)
	}


	meta_data, window, renderer := g4n.init_sdl()
	defer g4n.quit_sdl(window, renderer)

	// Creating and loading the g_state state are seperate tasks.
	// Although, obviously, "loading" the g_state state does not involve loading all assets at once.
	// Rather, this loads what we want at the start of the g_state: aka, before any execution at all.
	g_state := create_game_state(meta_data, window, renderer)
	load_initial_game_state(&g_state)
	defer destroy_game_state(&g_state)
	//-------------------------------------------------------

	log.logf(.Info, "\n\n\n== GAME LOOP ==")
	log.logf(.Info, "Starting game loop.")
	for !g_state.quit {
		game_loop(&g_state)

		when GLOBAL_DEBUG_LEVEL > .Release {
			g4n.check_tracking_allocator(&t_alloc)
		}
	}
	log.logf(.Info, "\n\n\n== SHUTDOWN ==")

	log.logf(.Info, "Beggining Shutdown")
}

game_loop :: proc(g_state: ^Game_State) {
	// Tracks delta time, aka time elapsed since last frame
	g4n.update_timesteps(&g_state.clock)
	//----------------------------------

	game_handle_events(g_state)
	game_update(g_state)
	game_render(g_state)
	
	when GLOBAL_DEBUG_LEVEL >= .Debug_Slow {
		sdl.Delay(DEBUG_MS_WAIT)
	}
}

game_update :: proc(g_state: ^Game_State) {
	if ecs.check_entity_has_component(&g_state.ecs_state, .Position_CE, g_state.player) {
		ecs.update_logical_position_from_component(
			ecs.get_entities_component(&g_state.ecs_state.position_cc, g_state.player)
		)
	}
	

	if ecs.check_entity_has_component(&g_state.ecs_state, .Physics_CE, g_state.player) {
		if ecs.check_entity_has_component(&g_state.ecs_state, .HumanoidMovement_CE, g_state.player) {
			ecs.humanoid_move_component_on_physics(
				ecs.get_entities_component(&g_state.ecs_state.humanoid_movement_cc, g_state.player),
				ecs.get_entities_component(&g_state.ecs_state.physics_cc, g_state.player),
			)
		}

		if ecs.check_entity_has_component(&g_state.ecs_state, .Position_CE, g_state.player) {
			ecs.update_physics_component(
				ecs.get_entities_component(&g_state.ecs_state.physics_cc, g_state.player),
				ecs.get_entities_component(&g_state.ecs_state.position_cc, g_state.player),
				g_state.clock.dt
			)
		}
	}
}

game_render :: proc(g_state: ^Game_State) {
	sdl.SetRenderDrawColor(g_state.renderer, 0, 0, 0, 255)
	sdl.RenderClear(g_state.renderer)

	sdl.SetRenderDrawColor(g_state.renderer, 255, 255, 255, 255)
	dest := g4n.to_sdl_frect(g4n.meta_as_window_sdlrect(g_state.meta_data))

	background := g4n.get_tile_texture_with_key(g_state.texture_sets, g4n.Texture_Key{"init", "map/car.bmp"})
	sdl.RenderTexture(g_state.renderer, background, nil, &dest)

	g4n.draw_tile_map(g_state.renderer, g_state.tile_map, g_state.tile_info, g_state.texture_sets, g_state.view_camera)
	if .Render_CE in g_state.ecs_state.entity_bitsets[g_state.player] && .Position_CE in g_state.ecs_state.entity_bitsets[g_state.player] {
		ecs.render_render_component(
			g_state.renderer, g_state.texture_sets,
			g_state.ecs_state.render_cc.components[g_state.ecs_state.render_cc.sparse_set[g_state.player]],
			g_state.ecs_state.position_cc.components[g_state.ecs_state.position_cc.sparse_set[g_state.player]],
		)
	}

	sdl.SetRenderDrawColor(g_state.renderer, 0, 255, 0, 255)
	sdl.RenderLine(g_state.renderer, f32(g_state.meta_data.window_width / 2), 0, f32(g_state.meta_data.window_width / 2), f32(g_state.meta_data.window_height))
	sdl.RenderLine(g_state.renderer, 0, f32(g_state.meta_data.window_height / 2), f32(g_state.meta_data.window_width), f32(g_state.meta_data.window_height / 2))
	
	sdl.RenderPresent(g_state.renderer)
}
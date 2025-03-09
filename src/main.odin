package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:c/libc"
import olog "core:log" 
import "core:mem"
import sdl "vendor:sdl3"

main :: proc() {
	context.logger = olog.create_console_logger()

	default_allocator := context.allocator
	tracking_allocator: mem.Tracking_Allocator
	mem.tracking_allocator_init(&tracking_allocator, default_allocator)
	context.allocator = mem.tracking_allocator(&tracking_allocator)

	reset_tracking_allocator :: proc(a: ^mem.Tracking_Allocator) -> bool {
		err := false

		for _, value in a.allocation_map {
			fmt.printf("%v: Leaked %v bytes\n", value.location, value.size)
			err = true
		}

		mem.tracking_allocator_clear(a)
		return err
	}

	defer {
		if reset_tracking_allocator(&tracking_allocator) {
			libc.getchar()
		}
	
		mem.tracking_allocator_destroy(&tracking_allocator)
	}

	init_logs("", "special_")
    log("Hello World!")

	game: Game = {}
	// Only for pre-sdl stuff like metadata.
	init_game(&game)
	//fmt.printfln("%v", game.texture_sets["entity"])
	init_sdl(&game)

	// Does the rest of the "init" for the game struct.
	load_game(&game)

	for !game.quit {
		game_loop(&game)

		if len(tracking_allocator.bad_free_array) > 0 {
			for b in tracking_allocator.bad_free_array {
				olog.errorf("Bad free at: %v", b.location)
			}

			libc.getchar()
			panic("Bad free detected")
		}
	}

	log("Goodbye World.")
}

game_loop :: proc(game: ^Game) {
	update_timesteps(&game.timing)
	game.timing.dt = get_deltatime(game.timing)
	if (game.timing.timestepsIndex == 0) { game.timing.fps = cast(int) (1.0 / game.timing.dt) }

	game_handle_events(game)
	
	game_update(game)

	game_render(game)

	//sdl.Delay(1)
}

game_update :: proc(game: ^Game) {
	update_player_entity(&game.player, game.timing.dt)
}

game_render :: proc(game: ^Game) {
	sdl.SetRenderDrawColor(game.renderer, 0, 0, 0, 255)
	sdl.RenderClear(game.renderer)

	sdl.SetRenderDrawColor(game.renderer, 255, 255, 255, 255)
	background : ^^sdl.Texture = &game.texture_sets["map"].textures["car.bmp"]
	//sdl.RenderTexture(game.renderer, background^, nil, &dest)

	start_camera_render(&game.view_camera)

	draw_tilemap(game.tile_map, game.tile_info, game.renderer)

	draw_player_entity(game.player, game.renderer)

	end_camera_render(&game.view_camera)

	sdl.SetRenderDrawColor(game.renderer, 255, 255, 255, 255)

	ui_rect := sdl.FRect{ 0, 0, 100, 50 }
	sdl.RenderFillRect(game.renderer, &ui_rect)

	sdl.SetRenderDrawColor(game.renderer, 0, 0, 0, 255)
	sdl.RenderDebugTextFormat(game.renderer, 10, 10, "FPS = %d", game.timing.fps)
	sdl.RenderDebugTextFormat(game.renderer, 10, 20, "pos = %.1f", game.player.position.x)
	sdl.RenderPresent(game.renderer)
}
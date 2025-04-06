package main
import sdl "vendor:sdl3"
import g4n "../g4n"
import "core:fmt"
import "core:mem"

main :: proc() {
	tracking_allocator := g4n.create_tracking_allocator()
	context.allocator = mem.tracking_allocator(&tracking_allocator)
	defer g4n.destroy_tracking_allocator(&tracking_allocator)

	g4n.init_logs("", "ecs_")
    g4n.log("Hello World!")

	game: Game = {}
	s_intrinsics := g4n.pre_sdl_init()
	g4n.init_sdl(&s_intrinsics)
	init_game(&game, s_intrinsics)
	init_load_game(&game)

	defer g4n.end_sdl(&game.sdl_intrinsics)
	defer cleanup_game(&game)

	for !game.sdl_intrinsics.quit {
		game_loop(&game)

		g4n.check_tracking_allocator(&tracking_allocator)
	}

	g4n.log("Goodbye World.")
}

game_loop :: proc(game: ^Game) {
	g4n.update_timesteps(&game.timing)
	game.timing.dt = g4n.get_deltatime(game.timing)

	game_handle_events(game)
	game_update(game)
	game_render(game)
	//sdl.Delay(1)
}

game_update :: proc(game: ^Game) {
	//update_player_entity(&game.player, game.global_entity_acceleration, game.tile_map, game.tile_info, game.timing.dt)
}

game_render :: proc(game: ^Game) {
	sdl.SetRenderDrawColor(game.sdl_intrinsics.renderer, 0, 0, 0, 255)
	sdl.RenderClear(game.sdl_intrinsics.renderer)

	sdl.SetRenderDrawColor(game.sdl_intrinsics.renderer, 255, 255, 255, 255)
	background : ^^sdl.Texture = &game.texture_sets["debug"].textures["map/img/car.bmp"]

	dest := sdl.FRect{0, 0, f32(game.sdl_intrinsics.meta_data.window_width), f32(game.sdl_intrinsics.meta_data.window_height)}

	sdl.RenderTexture(game.sdl_intrinsics.renderer, background^, nil, &dest)

	//start_camera_render(&game.view_camera)
	//draw_tilemap(game.tile_map, game.tile_info, game.view_camera, game.sdl_intrinsics.renderer)
	//draw_player_entity(game.player, game.view_camera, game.sdl_intrinsics.renderer)

	//end_camera_render(&game.view_camera)

	sdl.SetRenderDrawColor(game.sdl_intrinsics.renderer, 255, 255, 255, 255)
	ui_rect := sdl.FRect{ 0, 0, 120, 70 }
	sdl.RenderFillRect(game.sdl_intrinsics.renderer, &ui_rect)

	sdl.SetRenderDrawColor(game.sdl_intrinsics.renderer, 0, 0, 0, 255)
	//sdl.RenderDebugTextFormat(game.renderer, 10, 30, "vel = %d", game.player.velocity.y)
	sdl.RenderPresent(game.sdl_intrinsics.renderer)
}
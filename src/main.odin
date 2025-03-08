package main

import "core:fmt"
import "core:os"
import "core:strings"
import sdl "vendor:sdl3"

handle_keydown_event :: proc(game: ^Game, scan_code: sdl.Scancode, key_code: sdl.Keycode) {
	#partial switch scan_code {
	case .ESCAPE:
		game.quit = true
	case .L:
		log("", get_uptime(), "Manual scancode key log.")
	case .V:
		new_vsync : i32 = 1
		if game.meta_data.vsync == 1 { new_vsync = 0 }
		change_meta_vsync(&game.meta_data, &game.renderer, new_vsync)
	case .F:
		new_fullscreen := true
		if game.meta_data.fullscreen { new_fullscreen = false }
		change_meta_fullscreen(&game.meta_data, &game.window, new_fullscreen)
	}

	handle_player_input_keydown(&game.player, scan_code, key_code)
}

handle_keyup_event :: proc(game: ^Game, scan_code: sdl.Scancode, key_code: sdl.Keycode) {
	handle_player_input_keyup(&game.player, scan_code, key_code)
}

game_handle_events :: proc(game: ^Game) {
	for sdl.PollEvent(&game.event) {
		#partial switch game.event.type {	
		case .QUIT:
			game.quit = true
			return

		case .KEY_DOWN:
			if !game.event.key.repeat { handle_keydown_event(game, game.event.key.scancode, game.event.key.key) }

		case .KEY_UP:
			if !game.event.key.repeat { handle_keyup_event(game, game.event.key.scancode, game.event.key.key) }
		}
	}
}

game_update :: proc(game: ^Game) {
	update_player_entity(&game.player, game.timing.dt)
}

game_render :: proc(game: ^Game) {
	sdl.SetRenderDrawColor(game.renderer, 0, 0, 0, 255)
	sdl.RenderClear(game.renderer)

	sdl.SetRenderDrawColor(game.renderer, 255, 255, 255, 255)
	sdl.RenderDebugTextFormat(game.renderer, 10, 10, "FPS = %d", game.timing.fps)

	background : ^^sdl.Texture = &game.texture_sets["debug"].textures["car.bmp"]

	sdl.RenderTexture(game.renderer, background^, nil, nil)

	draw_player_entity(&game.player, game.renderer)

	sdl.RenderPresent(game.renderer)
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

main :: proc() {
	init_logs("", "special_")
    log("Hello World!")

	game: Game = {}
	init_game(&game)
	init_sdl(&game)

	load_game(&game)

	for !game.quit { game_loop(&game) }

	log("Goodbye World.")

	cleanup_game(&game)
	end_sdl(&game)
}
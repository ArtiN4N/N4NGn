package main

import "core:fmt"
import "core:os"
import "core:strings"
import sdl "vendor:sdl3"
import g4n "../g4n"
import ecs "../ecs"

// Note that key handling events use both scancodes and keycodes.
// Scancodes refer to the physical location on keyboard, and dont care about what a key is called.
// Great for joystick-like purposes, like WASD and such.
// Keycodes refer to the actual name of the key. This can cause problems with international keyboards,
// but is better if we want specific keys, like the escape key or the enter key.

handle_keydown_event :: proc(game: ^Game, scan_code: sdl.Scancode, key_code: sdl.Keycode) {
	#partial switch scan_code {
	case .L:
		g4n.log("Manual scancode key log = %v", g4n.get_uptime())
	case .V:
		g4n.toggle_vsync(&game.sdl_intrinsics.meta_data, &game.sdl_intrinsics.renderer)
	case .F:
		g4n.toggle_fullscreen(&game.sdl_intrinsics.meta_data, &game.sdl_intrinsics.window)
	}

	switch key_code {
		case sdl.K_ESCAPE:
			game.sdl_intrinsics.quit = true
	}

	handle_player_input_keydown(&game.ecs_state, game.player, scan_code, key_code)
}

handle_keyup_event :: proc(game: ^Game, scan_code: sdl.Scancode, key_code: sdl.Keycode) {
	handle_player_input_keyup(&game.ecs_state, game.player, scan_code, key_code)
}

// Remember that key down and up events are manually retriggered by sdl if a key is helf down.
// This needs to be handled with the event.key.repeat variable.
game_handle_events :: proc(game: ^Game) {
	for sdl.PollEvent(&game.event) {
		#partial switch game.event.type {	
		case .QUIT:
			game.sdl_intrinsics.quit = true
			return

		case .KEY_DOWN:
			if !game.event.key.repeat { handle_keydown_event(game, game.event.key.scancode, game.event.key.key) }

		case .KEY_UP:
			if !game.event.key.repeat { handle_keyup_event(game, game.event.key.scancode, game.event.key.key) }
		}
	}
}
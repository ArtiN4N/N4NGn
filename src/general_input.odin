package main

import "core:fmt"
import "core:os"
import "core:strings"
import sdl "vendor:sdl3"

// Note that key handling events use both scancodes and keycodes.
// Scancodes refer to the physical location on keyboard, and dont care about what a key is called.
// Great for joystick-like purposes, like WASD and such.
// Keycodes refer to the actual name of the key. This can cause problems with international keyboards,
// but is better if we want specific keys, like the escape key or the enter key.

handle_keydown_event :: proc(game: ^Game, scan_code: sdl.Scancode, key_code: sdl.Keycode) {
	#partial switch scan_code {
	case .L:
		log("", get_uptime(), "Manual scancode key log.")
	case .V:
		// toggle vsync
		new_vsync : i32 = 1
		if game.meta_data.vsync == 1 { new_vsync = 0 }
		change_meta_vsync(&game.meta_data, &game.renderer, new_vsync)
	case .F:
		// toggle fullscreen
		new_fullscreen := true
		if game.meta_data.fullscreen { new_fullscreen = false }
		change_meta_fullscreen(&game.meta_data, &game.window, new_fullscreen)
	}

	switch key_code {
		case sdl.K_ESCAPE:
			game.quit = true
	}

	handle_player_input_keydown(&game.player, scan_code, key_code)
}

handle_keyup_event :: proc(game: ^Game, scan_code: sdl.Scancode, key_code: sdl.Keycode) {
	handle_player_input_keyup(&game.player, scan_code, key_code)
}

// Remember that key down and up events are manually retriggered by sdl if a key is helf down.
// This needs to be handled with the event.key.repeat variable.
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
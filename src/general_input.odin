package main

import sdl "vendor:sdl3"
import g4n "../g4n"
import ecs "../ecs"

import "core:os"
import "core:fmt"
import "core:log"
import "core:strings"

// Note that key handling events use both scancodes and keycodes.
// Scancodes refer to the physical location on keyboard, and dont care about what a key is called.
// Great for joystick-like purposes, like WASD and such.
// Keycodes refer to the actual name of the key. This can cause problems with international keyboards,
// but is better if we want specific keys, like the escape key or the enter key.

handle_keydown_event :: proc(g_state: ^Game_State, scan_code: sdl.Scancode, key_code: sdl.Keycode) {
	#partial switch scan_code {
	case .V:
		g4n.toggle_vsync(&g_state.meta_data, g_state.renderer)
	case .F:
		g4n.toggle_fullscreen(&g_state.meta_data, g_state.window)
	}

	switch key_code {
		case sdl.K_ESCAPE:
			log.logf(.Info, "User has initiated shutdown with key %v.", sdl.K_ESCAPE)
			g_state.quit = true
	}

	handle_player_input_keydown(&g_state.ecs_state, g_state.player, scan_code, key_code)
}

handle_keyup_event :: proc(g_state: ^Game_State, scan_code: sdl.Scancode, key_code: sdl.Keycode) {
	handle_player_input_keyup(&g_state.ecs_state, g_state.player, scan_code, key_code)
}

// Polls available sdl events, and handles them.
game_handle_events :: proc(g_state: ^Game_State) {
	event: sdl.Event
	for sdl.PollEvent(&event) {
		#partial switch event.type {	
		case .QUIT:
			log.logf(.Info, "User has initiated shutdown with a quit event.")
			g_state.quit = true
			return
		
		// Sdl will keep polling a keydown/up with the repeat flag.
		// Right now we dont want this, so just ignore those cases
		case .KEY_DOWN:
			if !event.key.repeat { handle_keydown_event(g_state, event.key.scancode, event.key.key) }

		case .KEY_UP:
			if !event.key.repeat { handle_keyup_event(g_state, event.key.scancode, event.key.key) }
		}
	}
}
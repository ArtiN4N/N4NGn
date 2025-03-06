package main

import "core:fmt"
import "core:os"
import "core:strings"
import sdl "vendor:sdl3"

WINDOW_TITLE :: "Window Title"
SCREEN_WIDTH :: 800
SCREEN_HEIGHT :: 600

Game :: struct {
    window:   ^sdl.Window,
    renderer: ^sdl.Renderer,
    event:    sdl.Event,
	quit: bool,
}

get_uptime :: proc() -> f32 {
	return (cast(f32) sdl.GetTicks()) / 1000.0
}

game_cleanup :: proc(game: ^Game) {
	sdl.DestroyRenderer(game.renderer) 
	sdl.DestroyWindow(game.window)

	sdl.Quit()

	log("", -1, "Cleanup successful.")
}

initialize :: proc(game: ^Game) -> bool {
	sdl_init_flags : sdl.InitFlags = {.EVENTS, .VIDEO}
	if !sdl.Init(sdl_init_flags) {
		log("", get_uptime(), "Error initializing SDL. SDL error message: %s", sdl.GetError())
		return false
	}
	log("", get_uptime(), "Initialized SDL.")

	sdl_window_flags : sdl.WindowFlags = {.RESIZABLE}
	game.window = sdl.CreateWindow(WINDOW_TITLE, SCREEN_WIDTH, SCREEN_HEIGHT, sdl_window_flags)

	if game.window == nil {
		log("", get_uptime(), "Error creating SDL2 window. SDL error message: %s", sdl.GetError())
		return false
	}
	log("", get_uptime(), "Initialized SDL window.")

	game.renderer = sdl.CreateRenderer(game.window, nil)
	if game.renderer == nil {
		log("", get_uptime(), "Error creating SDL2 renderer. SDL error message: %s", sdl.GetError())
		return false
	}
	log("", get_uptime(), "Initialized SDL renderer.")

	return true
}

handle_key_event :: proc(game: ^Game, key_code: sdl.Scancode) {
	#partial switch key_code {
	case .ESCAPE:
		game.quit = true
	case .L:
		log("", get_uptime(), "Manual key log.")
	}
}


game_run :: proc(game: ^Game) {
	for sdl.PollEvent(&game.event) {
		#partial switch game.event.type {

		case .QUIT:
			game.quit = true
			return

		case .KEY_DOWN:
			handle_key_event(game, game.event.key.scancode)
		}
	}

	sdl.RenderClear(game.renderer)

	sdl.RenderPresent(game.renderer)

	sdl.Delay(16)
}

main :: proc() {
	game: Game

	init_logs("", "special_")
    log("", get_uptime(), "Hello World!")

	if !initialize(&game) { return }
	defer game_cleanup(&game)

	for !game.quit { game_run(&game) }

	log("", -1, "Goodbye World.")
}
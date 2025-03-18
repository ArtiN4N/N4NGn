package main

import "core:fmt"
import "core:os"
import "core:strings"
import sdl "vendor:sdl3"
import img "vendor:sdl3/image"

// Global INIT 2
init_sdl :: proc(game: ^Game) {
	md := game.meta_data

	if !sdl.Init(md.sdl_init_flags) {
		log("Error initializing SDL. SDL error message: %s", sdl.GetError())
		game.quit = true
		return
	}
	log("Initialized SDL.")

	cstr_title := strings.clone_to_cstring(md.window_title)
	sdl.CreateWindowAndRenderer(
		cstr_title, md.window_width, md.window_height, md.sdl_window_flags,
		&game.window, &game.renderer
	)

	delete(cstr_title)

	if game.window == nil || game.renderer == nil {
		log("Error creating SDL2 window or renderer. SDL error message: %s", sdl.GetError())
		game.quit = true
		return
	}
	
	log("Initialized SDL window.")
	log("Initialized SDL renderer.")

	set_vsync(&game.meta_data, &game.renderer, 1)
	set_fullscreen(&game.meta_data, &game.window, false)

	sdl.SetRenderDrawBlendMode(game.renderer, sdl.BLENDMODE_BLEND)

	log("Finished global init 2.")
}

// global shutdown 2
end_sdl :: proc(game: ^Game) {
	sdl.DestroyRenderer(game.renderer) 
	sdl.DestroyWindow(game.window)

	log("Finished global shutdown 2.")

	sdl.Quit()
}
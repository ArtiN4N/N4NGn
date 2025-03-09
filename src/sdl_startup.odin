package main

import "core:fmt"
import "core:os"
import "core:strings"
import sdl "vendor:sdl3"
import img "vendor:sdl3/image"

@(deferred_in=end_sdl)
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

	change_meta_vsync(&game.meta_data, &game.renderer, 1)
	change_meta_fullscreen(&game.meta_data, &game.window, false)

	return
}

end_sdl :: proc(game: ^Game) {
	sdl.DestroyRenderer(game.renderer) 
	sdl.DestroyWindow(game.window)

	log("Cleanup successful.")

	sdl.Quit()
}
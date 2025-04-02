package g4n
import sdl "vendor:sdl3"
import img "vendor:sdl3/image"
import "core:strings"


// Second global init to start SDL
init_sdl :: proc(intrinsics: ^SDLIntrinsics) {
	md := &intrinsics.meta_data
	if !sdl.Init(md.sdl_init_flags) {
		log("Error initializing SDL. SDL error message: %s", sdl.GetError())
		intrinsics.quit = true
		return
	}
	log("Initialized SDL.")

	cstr_title := strings.clone_to_cstring(md.window_title)
	sdl.CreateWindowAndRenderer(
		cstr_title, md.window_width, md.window_height, md.sdl_window_flags,
		&intrinsics.window, &intrinsics.renderer
	)

	delete(cstr_title)

	if intrinsics.window == nil || intrinsics.renderer == nil {
		log("Error creating SDL2 window or renderer. SDL error message: %s", sdl.GetError())
		intrinsics.quit = true
		return
	}
	
	log("Initialized SDL window.")
	log("Initialized SDL renderer.")

	set_vsync(md, &intrinsics.renderer, 1)
	set_fullscreen(md, &intrinsics.window, false)

	sdl.SetRenderDrawBlendMode(intrinsics.renderer, sdl.BLENDMODE_BLEND)

	log("Finished global init 2.")
}

// global shutdown 2
end_sdl :: proc(intrinsics: ^SDLIntrinsics) {
	sdl.DestroyRenderer(intrinsics.renderer) 
	sdl.DestroyWindow(intrinsics.window)

	log("Finished global shutdown 2.")

	sdl.Quit()
}
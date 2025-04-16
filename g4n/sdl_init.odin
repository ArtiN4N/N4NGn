package g4n
import sdl "vendor:sdl3"
import img "vendor:sdl3/image"
import "core:strings"
import "core:log"

// Creates and applies meta data, initializes sdl, and creates the vital window and renderer.
@(require_results)
init_sdl :: proc() -> (meta_data: SDL_Meta_Data, window: ^sdl.Window, renderer: ^sdl.Renderer) {
	// Creates meta data for SDL init and other procs
	// See meta.odin for the default constant declarations
	meta_data = create_meta_data()

	if !sdl.Init(meta_data.sdl_init_flags) {
		log.logf(.Fatal, "Could not initialize SDL!")
		panic("FATAL crash! See log file for info.")
	}
	log.logf(.Info, "Initialized SDL.")

	cstr_title := strings.clone_to_cstring(meta_data.window_title)
	sdl.CreateWindowAndRenderer(
		cstr_title, meta_data.window_width, meta_data.window_height, meta_data.sdl_window_flags,
		&window, &renderer
	)

	delete(cstr_title)

	if window == nil || renderer == nil {
		log.logf(.Fatal, "Could not initialize SDL window or renderer! SDL error message: %s", sdl.GetError())
		panic("FATAL crash! See log file for info.")
	}
	
	log.logf(.Info, "Initialized SDL window.")
	log.logf(.Info, "Initialized SDL renderer.")

	// see https://wiki.libsdl.org/SDL3/SDL_BlendMode
	// Sets blend mode to alpha blending.
	blend_mode := meta_data.blend_mode
	sdl.SetRenderDrawBlendMode(renderer, blend_mode)
	log.logf(.Info, "Set SDL blend mode to %v.", blend_mode)

	log.logf(.Debug, "Completed SDL initialization.")

	return
}

quit_sdl :: proc(window: ^sdl.Window, renderer: ^sdl.Renderer) {
	sdl.DestroyRenderer(renderer)
	log.logf(.Info, "Destroyed SDL renderer.")
	sdl.DestroyWindow(window)
	log.logf(.Info, "Destroyed SDL window.")

	sdl.Quit()

	log.logf(.Debug, "Completed SDL shutdown.")
}
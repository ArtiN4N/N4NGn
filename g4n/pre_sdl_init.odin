package g4n
import sdl "vendor:sdl3"

SDLIntrinsics :: struct {
    window: ^sdl.Window,
    renderer: ^sdl.Renderer,
    quit: bool,
    meta_data: SDLMetaData,
}

// First global init to prep for sdl
pre_sdl_init :: proc() -> (intrinsics: SDLIntrinsics) {
    intrinsics.window = nil
    intrinsics.renderer = nil

    intrinsics.quit = false

    intrinsics.meta_data = init_meta_data()

    log("Finished pre-sdl global init 1.")

    return
}
package g4n
import sdl "vendor:sdl3"

DEFAULT_WINDOW_WIDTH :: 1000
DEFAULT_WINDOW_HEIGHT :: 800
DEFAULT_WINDOW_TITLE :: "Title name"
DEFAULT_VSYNC :: 1
DEFAULT_INIT_FLAGS : sdl.InitFlags : {.EVENTS, .VIDEO}

// Just metadata for the sdl window and application.
SDLMetaData :: struct {
    sdl_init_flags: sdl.InitFlags,
    sdl_window_flags: sdl.WindowFlags,

    vsync: i32,
    fullscreen: bool,

    window_title: string,
    window_width: i32,
    window_height: i32,
}

// Happens before SDL is init
init_meta_data :: proc(
    flags : sdl.InitFlags = DEFAULT_INIT_FLAGS,
    window_title : string = DEFAULT_WINDOW_TITLE, window_width : i32 = DEFAULT_WINDOW_WIDTH, window_height : i32 = DEFAULT_WINDOW_HEIGHT,
) -> (md : SDLMetaData) {
    // Remember to update this to inclue all aspects of sdl that are needed.
    md.sdl_init_flags = flags
    md.sdl_window_flags = {}

    md.vsync = DEFAULT_VSYNC
    md.window_title = window_title
    md.window_width = window_width
    md.window_height = window_height

    return
}

// Any changes to vsync should come through these procs
set_vsync :: proc(md: ^SDLMetaData, renderer: ^^sdl.Renderer, new_vsync: i32) {
    md.vsync = new_vsync
    sdl.SetRenderVSync(renderer^, new_vsync)
    log("VSync set to %v.", new_vsync)
}

toggle_vsync :: proc(md: ^SDLMetaData, renderer: ^^sdl.Renderer) {
    if md.vsync == 0 { md.vsync = 1}
    else { md.vsync = 0 }

    sdl.SetRenderVSync(renderer^, md.vsync)
    log("VSync set to %v.", md.vsync)
}

// Any changes to fullscreen status should come through these procs
set_fullscreen :: proc(md: ^SDLMetaData, window: ^^sdl.Window, new_fullscreen: bool) {
    md.fullscreen = new_fullscreen
    sdl.SetWindowFullscreen(window^, new_fullscreen)
    log("Fullscreen set to %v.", new_fullscreen)

    width : i32
    height : i32
    sdl.GetWindowSizeInPixels(window^, &width, &height)

    md.window_width = width
    md.window_height = height
    log("Window size set to %v,%v.", width, height)
}

toggle_fullscreen :: proc(md: ^SDLMetaData, window: ^^sdl.Window) {
    md.fullscreen = !md.fullscreen
    sdl.SetWindowFullscreen(window^, md.fullscreen)
    log("Fullscreen set to %v.", md.fullscreen)

    width : i32
    height : i32
    sdl.GetWindowSizeInPixels(window^, &width, &height)

    md.window_width = width
    md.window_height = height
    log("Window size set to %v,%v.", width, height)
}

// Any changes to window size should come through here
change_meta_window_size :: proc(md: ^SDLMetaData, window: ^^sdl.Window, new_width, new_height : i32) {
    if md.fullscreen {
        log("Uh oh! Tried to change screen size while fullscreen.")
        return
    }

    md.window_width = new_width
    md.window_height = new_height
    sdl.SetWindowSize(window^, new_width, new_height)
    log("Window size set to %v,%v.", new_width, new_height)
}
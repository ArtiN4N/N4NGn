package g4n
import sdl "vendor:sdl3"

import "core:log"

DEFAULT_VSYNC :: 1
DEFAULT_FULLSCREEN :: false
// https://wiki.libsdl.org/SDL3/SDL_BlendMode
DEFAULT_BLENDMODE :: sdl.BLENDMODE_BLEND

DEFAULT_WINDOW_WIDTH :: 1000
DEFAULT_WINDOW_HEIGHT :: 800
DEFAULT_WINDOW_TITLE :: "Title name"

DEFAULT_INIT_FLAGS : sdl.InitFlags : {.EVENTS, .VIDEO}

// Just metadata for the sdl window and application.
SDL_Meta_Data :: struct {
    sdl_init_flags: sdl.InitFlags,
    sdl_window_flags: sdl.WindowFlags,

    vsync: i32,
    fullscreen: bool,
    blend_mode: sdl.BlendMode,

    window_title: string,
    window_width: i32,
    window_height: i32,
}

// Happens before SDL is init
create_meta_data :: proc(
    flags : sdl.InitFlags = DEFAULT_INIT_FLAGS,
    window_title : string = DEFAULT_WINDOW_TITLE, window_width : i32 = DEFAULT_WINDOW_WIDTH, window_height : i32 = DEFAULT_WINDOW_HEIGHT,
) -> (md : SDL_Meta_Data) {
    md.sdl_init_flags = flags
    md.sdl_window_flags = {}

    md.vsync = DEFAULT_VSYNC
    md.fullscreen = DEFAULT_FULLSCREEN
    md.blend_mode = DEFAULT_BLENDMODE

    md.window_title = window_title
    md.window_width = window_width
    md.window_height = window_height

    log.logf(.Info, "Created Meta Data.")
    return
}

// Any changes to vsync should come through these procs
set_vsync :: proc(md: ^SDL_Meta_Data, renderer: ^sdl.Renderer, new_vsync: i32) {
    md.vsync = new_vsync
    sdl.SetRenderVSync(renderer, new_vsync)
    log.logf(.Info, "VSync set to %v.", md.vsync)
}

toggle_vsync :: proc(md: ^SDL_Meta_Data, renderer: ^sdl.Renderer) {
    if md.vsync == 0 { md.vsync = 1}
    else { md.vsync = 0 }

    sdl.SetRenderVSync(renderer, md.vsync)
    log.logf(.Info, "VSync set to %v.", md.vsync)
}

// Any changes to fullscreen status should come through these procs
set_fullscreen :: proc(md: ^SDL_Meta_Data, window: ^sdl.Window, new_fullscreen: bool) {
    md.fullscreen = new_fullscreen
    sdl.SetWindowFullscreen(window, new_fullscreen)
    log.logf(.Info, "Fullscreen set to %v.", md.fullscreen)

    width : i32
    height : i32
    sdl.GetWindowSizeInPixels(window, &width, &height)

    md.window_width = width
    md.window_height = height
    log.logf(.Info, "Window size set to %v,%v.", md.window_width, md.window_height)
}

toggle_fullscreen :: proc(md: ^SDL_Meta_Data, window: ^sdl.Window) {
    md.fullscreen = !md.fullscreen
    sdl.SetWindowFullscreen(window, md.fullscreen)
    log.logf(.Info, "Fullscreen set to %v.", md.fullscreen)

    width : i32
    height : i32
    sdl.GetWindowSizeInPixels(window, &width, &height)

    md.window_width = width
    md.window_height = height
    log.logf(.Info, "Window size set to %v,%v.", md.window_width, md.window_height)
}

// Any changes to window size should come through here
change_meta_window_size :: proc(md: ^SDL_Meta_Data, window: ^sdl.Window, new_width, new_height : i32) {
    if md.fullscreen {
        log.logf(.Warning, "Tried to set window size, failed because window is in fullscreen.")
        return
    }

    md.window_width = new_width
    md.window_height = new_height
    sdl.SetWindowSize(window, new_width, new_height)
    log.logf(.Info, "Window size set to %v,%v.", md.window_width, md.window_height)
}

meta_as_window_sdlrect :: proc(md: SDL_Meta_Data) -> (v: IRect) {
    return {(md.window_width - 1) / 2, (md.window_height - 1) / 2, md.window_width, md.window_height}
}

meta_as_window_size_vector :: proc(md: SDL_Meta_Data) -> (v: IVector) {
    return {md.window_width, md.window_height}
}
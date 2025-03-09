package main

import "core:fmt"
import "core:os"
import "core:strings"
import sdl "vendor:sdl3"

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
init_meta_data :: proc(md: ^SDLMetaData) {
    // Remember to update this to inclue all aspects of sdl that are needed.
    md.sdl_init_flags = {.EVENTS, .VIDEO}
    md.sdl_window_flags = {  }

    md.vsync = 1
    md.window_title = "This is the screen title"
    md.window_width = 800
    md.window_height = 800
}

// Any changes to vsync should come through here
change_meta_vsync :: proc(meta_data: ^SDLMetaData, renderer: ^^sdl.Renderer, new_vsync: i32) {
    meta_data.vsync = new_vsync
    sdl.SetRenderVSync(renderer^, new_vsync)
    log("VSync set to %v.", new_vsync)
}

// Any changes to fullscreen status should come through here
change_meta_fullscreen :: proc(meta_data: ^SDLMetaData, window: ^^sdl.Window, new_fullscreen: bool) {
    meta_data.fullscreen = new_fullscreen
    sdl.SetWindowFullscreen(window^, new_fullscreen)
    log("Fullscreen set to %v.", new_fullscreen)

    width : i32
    height : i32
    sdl.GetWindowSizeInPixels(window^, &width, &height)

    meta_data.window_width = width
    meta_data.window_height = height
    log("Window size set to %v,%v.", width, height)
}

// Any changes to window size should come through here
change_meta_window_size :: proc(meta_data: ^SDLMetaData, window: ^^sdl.Window, new_width, new_height : i32) {
    if meta_data.fullscreen {
        log("Uh oh! Tried to change screen size while fullscreen.")
        return
    }

    meta_data.window_width = new_width
    meta_data.window_height = new_height
    sdl.SetWindowSize(window^, new_width, new_height)
    log("Window size set to %v,%v.", new_width, new_height)
}
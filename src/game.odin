package main

import "core:fmt"
import "core:os"
import "core:strings"
import sdl "vendor:sdl3"
import img "vendor:sdl3/image"

Game :: struct {
    window: ^sdl.Window,
    renderer: ^sdl.Renderer,
    event: sdl.Event,
	quit: bool,
	timing: GameClock,
    meta_data: SDLMetaData,
    texture_sets: map[string]TextureSet
}

// Happens before SDL is init
init_game :: proc(game: ^Game) {
    // These are initialized in their own dedicated procedure
    game.window = nil
    game.renderer = nil

    game.quit = false

    init_game_clock(&game.timing)

    init_meta_data(&game.meta_data)

    game.texture_sets = make(map[string]TextureSet)

    init_debug_texture_set(&game.texture_sets)   
}

init_debug_texture_set :: proc(t_sets: ^map[string]TextureSet) {
    t_sets["debug"] = create_texture_set(
        "assets/img/",
        "car.bmp"
    )
}

cleanup_game :: proc(game: ^Game) {
    for key, &value in game.texture_sets {
        destroy_texture_set(&value, key)
    }

    delete(game.texture_sets)
}
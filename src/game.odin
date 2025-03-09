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
    // For stuff like if the window can be resized, fullscreened, etc
    meta_data: SDLMetaData,
    texture_sets: map[string]TextureSet,

    player: Entity,

    tile_map: TileMap,
    tile_info: TileInfo,
}

// Warning: this proc happens before SDL is init
@(deferred_in=cleanup_game)
init_game :: proc(game: ^Game) {
    // These are initialized in their own dedicated procedure
    game.window = nil
    game.renderer = nil

    game.quit = false

    init_game_clock(&game.timing)
    init_meta_data(&game.meta_data)

    game.texture_sets = make(map[string]TextureSet)

    // Manual procedures are used to create texture sets
    init_texture_sets(&game.texture_sets)
}

load_game :: proc(game: ^Game) {
    // Any texture sets here are likely to be loaded until the closing of the application
    load_texture_set(&game.texture_sets["entity"], &game.renderer, "entity")
    load_texture_set(&game.texture_sets["item"], &game.renderer, "item")
    load_texture_set(&game.texture_sets["map"], &game.renderer, "map")
    load_texture_set(&game.texture_sets["tile"], &game.renderer, "tile")

    init_player_entity(&game.player, &game.texture_sets["entity"].textures["teto.png"])

    init_tile_info(&game.tile_info, &game.texture_sets)
    init_tilemap(&game.tile_map, game.tile_info)
}

cleanup_game :: proc(game: ^Game) {
    for key, &value in game.texture_sets {
        destroy_texture_set(&value, key)
        delete(key)
    }

    delete(game.texture_sets)

    destroy_tilemap(&game.tile_map)
}
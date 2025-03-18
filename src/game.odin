package main

import "core:fmt"
import "core:os"
import "core:strings"
import sdl "vendor:sdl3"
import img "vendor:sdl3/image"

DEFAULT_WORLD_GRAVITY :: 880

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

    view_camera: Camera,

    // fancy gravity basically
    global_entity_acceleration: sdl.FPoint,
}

// Global INIT 1
pre_sdl_init :: proc(game: ^Game) {
    game.window = nil
    game.renderer = nil

    game.quit = false

    game.meta_data = init_meta_data()

    log("Finished pre-sdl global init 1.")
}

// global INIT 3
init_game :: proc(game: ^Game) {
    game.timing = create_game_clock()
    game.texture_sets = make(map[string]TextureSet)

    // Manual procedures are used to create texture sets
    init_texture_sets(&game.texture_sets)

    game.global_entity_acceleration.y = DEFAULT_WORLD_GRAVITY

    game.view_camera = create_camera(game.meta_data.window_width, game.meta_data.window_height, &game.player.discrete_position)

    log("Finished global init 3.")
}

// global INIT 4
init_load_game :: proc(game: ^Game) {
    // Any texture sets here are likely to be loaded until the closing of the application
    load_texture_set(&game.texture_sets["entity"], &game.renderer, "entity")
    load_texture_set(&game.texture_sets["item"], &game.renderer, "item")
    load_texture_set(&game.texture_sets["map"], &game.renderer, "map")
    load_texture_set(&game.texture_sets["tile"], &game.renderer, "tile")

    init_player_entity(&game.player, &game.texture_sets["entity"].textures["teto.png"])

    init_tile_info(&game.tile_info, &game.texture_sets)
    init_tilemap(&game.tile_map, game.tile_info)
    set_player_position_grid(&game.player, game.tile_map.player_spawn, game.tile_map.tile_size)

    log("Finished global init 4.")
}

// global shutdown 1
cleanup_game :: proc(game: ^Game) {
    for key, &value in game.texture_sets {
        destroy_texture_set(&value, key)
        delete(key)
    }

    delete(game.texture_sets)

    destroy_tilemap(&game.tile_map)

    log("Finished global shutdown 1.")
}
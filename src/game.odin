package main
import sdl "vendor:sdl3"
import img "vendor:sdl3/image"
import g4n "../g4n"
import ecs "../ecs"
import "core:fmt"
import "core:os"
import "core:strings"


DEFAULT_WORLD_GRAVITY :: 880

Game :: struct {
    sdl_intrinsics: g4n.SDLIntrinsics,
    event: sdl.Event,

	timing: g4n.GameClock,

    texture_sets: map[string]g4n.TextureSet,

    ecs_state: ecs.ECSState,

    tile_map: g4n.TileMap,
    tile_info: g4n.TileInfo,

    view_camera: g4n.Camera,
}



// global INIT 3
init_game :: proc(game: ^Game, sdl_i: g4n.SDLIntrinsics) {
    game.sdl_intrinsics = sdl_i
    game.timing = g4n.create_game_clock()
    game.texture_sets = make(map[string]g4n.TextureSet)

    // Manual procedures are used to create texture sets
    g4n.init_texture_sets(&game.texture_sets)

    //game.view_camera = g4n.create_camera(game.sdl_intrinsics.meta_data.window_width, game.sdl_intrinsics.meta_data.window_height, &game.player.discrete_position)

    g4n.log("Finished global init 3.")
}

// global INIT 4
init_load_game :: proc(game: ^Game) {
    // Any texture sets here are likely to be loaded until the closing of the application
    //g4n.load_texture_set(&game.texture_sets["entity"], &game.sdl_intrinsics.renderer, "entity")
    //g4n.load_texture_set(&game.texture_sets["item"], &game.sdl_intrinsics.renderer, "item")
    //g4n.load_texture_set(&game.texture_sets["map"], &game.sdl_intrinsics.renderer, "map")
    //g4n.load_texture_set(&game.texture_sets["tile"], &game.sdl_intrinsics.renderer, "tile")
    g4n.load_texture_set(&game.texture_sets["debug"], &game.sdl_intrinsics.renderer, "debug")

    //init_player_entity(&game.player, &game.texture_sets["entity"].textures["teto.png"])

    game.tile_info = g4n.create_tile_info(&game.texture_sets)
    g4n.init_tilemap(&game.tile_map, game.tile_info)
    
    game.ecs_state = ecs.create_ecs_state()

    g4n.log("Finished global init 4.")
}

// global shutdown 1
cleanup_game :: proc(game: ^Game) {
    for key, &value in game.texture_sets {
        g4n.destroy_texture_set(&value, key)
        delete(key)
    }

    delete(game.texture_sets)

    g4n.destroy_tilemap(&game.tile_map)

    ecs.destroy_ecs_state(&game.ecs_state)

    g4n.log("Finished global shutdown 1.")
}
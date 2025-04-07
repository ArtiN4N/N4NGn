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

    player: ecs.EntityID,
}



// global INIT 3
init_game :: proc(game: ^Game, sdl_i: g4n.SDLIntrinsics) {
    game.sdl_intrinsics = sdl_i
    game.timing = g4n.create_game_clock()
    game.texture_sets = make(map[string]g4n.TextureSet)

    // Manual procedures are used to create texture sets
    g4n.init_texture_sets(&game.texture_sets)

    g4n.log("Finished global init 3.")
}

create_player_entity :: proc(e_state: ^ecs.ECSState, player: ecs.EntityID, texture_sets: map[string]g4n.TextureSet, camera: ^g4n.Camera) {
    ecs.attach_ecs_component(e_state, player, ecs.PositionComponent, &e_state.position_cc, ecs.create_position_component_data(10, 10))
    player_position := ecs.get_entities_component(&e_state.position_cc, player)

    ecs.attach_ecs_component(
        e_state, player, ecs.PhysicsComponent, &e_state.physics_cc,
        ecs.create_physics_component_data(&player_position.physics_position, 50, 80, 0, 0, 10, 0)
    )
    player_physics := ecs.get_entities_component(&e_state.physics_cc, player)

    ecs.attach_ecs_component(
        e_state, player, ecs.HumanoidMovementComponent, &e_state.humanoid_movement_cc,
        ecs.create_humanoid_movement_component_data(100, 500)
    )
    ecs.attach_ecs_component(
        e_state, player, ecs.RenderComponent, &e_state.render_cc,
        ecs.create_render_component_data(50, 80, texture_sets["debug"].textures["entity/img/teto.png"], true, camera)
    )
    ecs.attach_ecs_component(
        e_state, player, ecs.RenderPhysicsComponent, &e_state.render_physics_cc,
        ecs.create_render_physics_component_data(sdl.Color{255, 0, 0, 255})
    )

    force := g4n.CompoundForce{g4n.FVector{0, 4000}, g4n.FVector{0, 0}, 0, 5}
	ecs.add_physics_component_accel_force(
		player_physics, force
	)
}

// global INIT 4
init_load_game :: proc(game: ^Game) {
    // Any texture sets here are likely to be loaded until the closing of the application
    g4n.load_texture_set(&game.texture_sets["debug"], &game.sdl_intrinsics.renderer, "debug")

    game.tile_info = g4n.create_tile_info(&game.texture_sets)
    g4n.init_tilemap(&game.tile_map, game.tile_info)
    
    game.ecs_state = ecs.create_ecs_state()

    ok : bool
    game.player, ok = ecs.create_entity(&game.ecs_state)
    if !ok { g4n.log("Uh oh! couldnt create player!.") }
    create_player_entity(&game.ecs_state, game.player, game.texture_sets, &game.view_camera)

    game.view_camera = g4n.create_camera(
        game.sdl_intrinsics.meta_data.window_width, game.sdl_intrinsics.meta_data.window_height,
        &ecs.get_entities_component(&game.ecs_state.position_cc, game.player).logic_position
    )

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
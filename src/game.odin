package main
import sdl "vendor:sdl3"
import img "vendor:sdl3/image"
import g4n "../g4n"
import ecs "../ecs"
import "core:fmt"
import "core:os"
import "core:strings"
import "core:log"

//DEFAULT_WORLD_GRAVITY :: 880

// Contains all data necessary for advancing the (actual, theoretical) game state
Game_State :: struct {
    window: ^sdl.Window,
    renderer: ^sdl.Renderer,
    quit: bool,
    meta_data: g4n.SDL_Meta_Data,

	clock: g4n.Game_Clock,

    texture_sets: g4n.Texture_Set_Map,

    ecs_state: ecs.ECS_State,

    tile_map: g4n.Tile_Map,
    tile_info: g4n.Tile_Info,

    view_camera: g4n.Camera,

    //player: ecs.Entity_Handle,
    player: ecs.EntityID,
}


@(require_results)
create_game_state :: proc(
    meta_data: g4n.SDL_Meta_Data, window: ^sdl.Window, renderer: ^sdl.Renderer
) -> (g_state: Game_State) {
    g_state.window = window
    g_state.renderer = renderer
    g_state.quit = false
    g_state.meta_data = meta_data
    
    g_state.clock = g4n.create_game_clock()

    g_state.texture_sets = make(g4n.Texture_Set_Map)
    log.logf(.Debug, "Created state's texture_sets data string -> Texture_Set map. Note: Different from a texture set itself.")

    g4n.init_texture_sets(&g_state.texture_sets)

    log.logf(.Info, "Completed game state initialization.")

    return
}

destroy_game_state :: proc(g_state: ^Game_State) {
    // Iterate through all texture sets, and destroy them
    for key, &value in g_state.texture_sets {
        g4n.destroy_texture_set(&value, key)
        log.logf(.Debug, "Texture set %s has destroyed set name string data.", key)
        delete(key)
    }
    delete(g_state.texture_sets)
    //---------------------------------------
    log.logf(.Debug, "Destroyed state's string -> Texture_Set map. Note: Different from a texture set itself.")

    g4n.destroy_tile_map(&g_state.tile_map)
    g4n.destroy_tile_info(&g_state.tile_info)
    ecs.destroy_ecs_state(&g_state.ecs_state)

    log.logf(.Info, "Completed game state destruction.")
}

// This loads in all assets + others that are wanted before any execution on the state can be done.
INITAL_TEXTURE_SET :: "init"
load_initial_game_state :: proc(g_state: ^Game_State) {
    // Any texture sets here are likely to be loaded until the closing of the application
    g4n.load_texture_set(&g_state.texture_sets[INITAL_TEXTURE_SET], g_state.renderer, INITAL_TEXTURE_SET)
    log.logf(.Debug, "Loaded initial game state texture set.")

    g_state.tile_info = g4n.create_tile_info()
    log.logf(.Debug, "Loaded initial game state tile info.")

    g_state.tile_map = g4n.create_tile_map(g_state.tile_info)
    log.logf(.Debug, "Loaded initial game state tile map.")
    
    g_state.ecs_state = ecs.create_ecs_state()
    log.logf(.Debug, "Loaded initial game state ecs state.")

    ok: bool
    if g_state.player, ok = ecs.create_entity(&g_state.ecs_state); !ok {
        log.logf(.Fatal, "Could not create the player entity.")
        panic("FATAL crash! See log file for info.")
    }
    init_player_entity(&g_state.ecs_state, g_state.player, g_state.texture_sets, &g_state.view_camera)
    log.logf(.Debug, "Loaded initial game state player entity.")

    g_state.view_camera = g4n.create_camera(
        g_state.meta_data.window_width, g_state.meta_data.window_height,
        &ecs.get_entities_component(&g_state.ecs_state.position_cc, g_state.player).logic_position
    )
    log.logf(.Debug, "Loaded initial game state camera.")

    log.logf(.Info, "Completed initial game state load.")
}

init_player_entity :: proc(
    e_state: ^ecs.ECS_State, player: ecs.EntityID,
    texture_sets: g4n.Texture_Set_Map, camera: ^g4n.Camera
) {
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
        ecs.create_render_component_data(50, 80, g4n.Texture_Key{"init", "entity/teto.png"}, true, camera)
    )
    ecs.attach_ecs_component(
        e_state, player, ecs.RenderPhysicsComponent, &e_state.render_physics_cc,
        ecs.create_render_physics_component_data(sdl.Color{255, 0, 0, 255})
    )

    force := g4n.create_compound_force(g4n.FVector{0, 4000}, 0, 5, true)
	ecs.add_physics_component_accel_force(
		player_physics, force
	)

    log.logf(.Info, "Completed initialization of game state player entity with entity handle %v.", player)
}
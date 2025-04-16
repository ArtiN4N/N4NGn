package main

import sdl "vendor:sdl3"
import img "vendor:sdl3/image"
import ecs "../ecs"

import "core:fmt"
import "core:os"
import "core:strings"
import "core:slice"
import "core:math"

handle_player_input_keydown :: proc(ecs_state: ^ecs.ECS_State, player: ecs.EntityID, scan_code: sdl.Scancode, key_code: sdl.Keycode) {
    if .HumanoidMovement_CE in ecs_state.entity_bitsets[player] {
        #partial switch scan_code {
            case .A:
                ecs.set_humanoid_move_component_xdir(
                    &ecs_state.humanoid_movement_cc.components[ecs_state.humanoid_movement_cc.sparse_set[player]],
                    ecs_state.humanoid_movement_cc.components[ecs_state.humanoid_movement_cc.sparse_set[player]].x_move_direction - 1
                )
            case .D:
                ecs.set_humanoid_move_component_xdir(
                    &ecs_state.humanoid_movement_cc.components[ecs_state.humanoid_movement_cc.sparse_set[player]],
                    ecs_state.humanoid_movement_cc.components[ecs_state.humanoid_movement_cc.sparse_set[player]].x_move_direction + 1
                )
        }
    
        switch key_code {
            case sdl.K_LSHIFT:
                ecs.set_humanoid_move_component_running(
                    &ecs_state.humanoid_movement_cc.components[ecs_state.humanoid_movement_cc.sparse_set[player]],
                    !ecs_state.humanoid_movement_cc.components[ecs_state.humanoid_movement_cc.sparse_set[player]].running
                )
        }
    }
}

handle_player_input_keyup :: proc(ecs_state: ^ecs.ECS_State, player: ecs.EntityID, scan_code: sdl.Scancode, key_code: sdl.Keycode) {
    if .HumanoidMovement_CE in ecs_state.entity_bitsets[player] {
        #partial switch scan_code {
            case .A:
                ecs.set_humanoid_move_component_xdir(
                    &ecs_state.humanoid_movement_cc.components[ecs_state.humanoid_movement_cc.sparse_set[player]],
                    ecs_state.humanoid_movement_cc.components[ecs_state.humanoid_movement_cc.sparse_set[player]].x_move_direction + 1
                )
            case .D:
                ecs.set_humanoid_move_component_xdir(
                    &ecs_state.humanoid_movement_cc.components[ecs_state.humanoid_movement_cc.sparse_set[player]],
                    ecs_state.humanoid_movement_cc.components[ecs_state.humanoid_movement_cc.sparse_set[player]].x_move_direction - 1
                )
                
        }

        switch key_code {
            case sdl.K_LSHIFT:
                
        }
    }
}

/*update_player_entity :: proc(player: ^Entity, global_entity_acceleration: sdl.FPoint, tmap: TileMap, tinfo: TileInfo, dt: f32) {
    player.grounded_timer += dt
    move_velocity := player.move_velocity
    //move_velocity.y = 0
    if player.is_walking { move_velocity.x *= player.walk_speed }
    else { move_velocity.x *= player.run_speed }

    if move_velocity.x > 0 {
        player.facing_right = true
    } else if move_velocity.x < 0 {
        player.facing_right = false
    }

    old_position := player.position

    if !player.grounded && !player.grabbing {
        player.global_velocity += global_entity_acceleration * dt
    }

    if !player.grounded && player.global_velocity.y > 0 && player.move_velocity.x != 0 {
        player.grabbing, player.grabbing_target_tile = tilemap_check_entity_grab(player.grab_hitbox, tmap, tinfo, player.collision_tier, player.facing_right)
        if player.grabbing { player.global_velocity.y = 0 }
    }

    player.velocity += player.acceleration * dt + player.move_acceleration * dt
    player.position += player.velocity * dt + move_velocity * dt + player.global_velocity * dt

    update_hitbox(&player.collision_hitbox)
    update_hitbox(&player.combat_hitbox)

    update_velocity := player.velocity + move_velocity + player.global_velocity

    corrected_pos, collided_x, collided_y := tilemap_collision_correction_split_axis(player.collision_hitbox, old_position, player.position, update_velocity, tmap, tinfo, player.collision_tier, dt)
    player.position = corrected_pos

    if collided_x {
        player.velocity.x = 0
    }

    if collided_y {
        player.velocity.y = 0
        player.global_velocity.y = 0
    }

    update_hitbox(&player.collision_hitbox)
    update_hitbox(&player.combat_hitbox)
    update_hitbox(&player.grab_hitbox)

    old_grounded := player.grounded

    player.grounded = tilemap_check_entity_grounded(player.collision_hitbox, tmap, tinfo, player.collision_tier)
    if player.grounded || player.grabbing {
        player.global_velocity = { 0, 0 }
    }

    if !player.grounded && old_grounded && player.global_velocity.y >= 0 {
        player.grounded_timer = 0.0
    }

    player.discrete_position = sdl.Point{ cast(i32) player.position.x, cast(i32) player.position.y }

    // grab:
    // when not grounded and falling and facing right and not holding down
    //      check hitbox with top of tiles to the right
}*/

/*draw_player_entity :: proc(player: Entity, camera: Camera, renderer: ^sdl.Renderer) {
    sdl.SetRenderDrawColor(renderer, 255, 255, 255, sdl.ALPHA_OPAQUE)

    player := player

    //round_decimals(&player.position.x, &player.position.y)

    texture_dest_size := player.texture_dest_size
    texture_dest_offset := player.texture_dest_offset

    if player.facing_right {
        texture_dest_size.x *= -1
        texture_dest_offset.x *= -1
    }

    src_rect := sdl.Rect{
        player.texture_src_position.x, player.texture_src_position.y,
        player.texture_src_size.x, player.texture_src_size.y,
    }

    dest_rect := sdl.Rect{
        player.discrete_position.x + texture_dest_offset.x, player.discrete_position.y + texture_dest_offset.y,
        texture_dest_size.x, texture_dest_size.y,
    }

    //sdl.RenderTexture(renderer, player.texture^, &src_rect, &dest_rect)
    render_texture_via_camera(camera, renderer, player.texture^, &src_rect, &dest_rect)

    position_rect := sdl.FRect{ player.position.x - 3, player.position.y - 3, 6, 6 }

    
    // debug player real position
    //sdl.SetRenderDrawColor(renderer, 0, 0, 255, sdl.ALPHA_OPAQUE)
    //sdl.RenderFillRect(renderer, &position_rect)
    
    // debug player hitbox
    //draw_hitbox(player.combat_hitbox, renderer)
    //draw_hitbox(player.collision_hitbox, renderer)
    if player.grabbing { draw_hitbox(player.grab_hitbox, camera, renderer) } 

    // debug occupied tiles
    
    occupied := make([dynamic]TilePoint)
    defer delete(occupied)

    for vec in player.collision_hitbox.corners {
        u_vec := vector_to_tile_position(vec, tmap^)
        append(&occupied, u_vec)
    }

    sdl.SetRenderDrawColor(renderer, 0, 0, 255, 100)
    rect : sdl.FRect = { 0, 0, cast(f32) tmap.tile_size, cast(f32) tmap.tile_size }
    for vec in occupied {
        rect.x = (cast(f32) vec.x) * (cast(f32) tmap.tile_size)
        rect.y = (cast(f32) vec.y) * (cast(f32) tmap.tile_size)

        //sdl.RenderFillRect(renderer, &rect)
    }
}*/

/*set_player_position_grid :: proc(player: ^Entity, pos: TilePoint, g_size: u32) {
    set_pos := sdl.FPoint{ cast(f32) (pos.x * g_size + g_size / 2), cast(f32) (pos.y * g_size + g_size / 2)}
    player.position = set_pos
}*/
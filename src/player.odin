package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:slice"
import sdl "vendor:sdl3"
import img "vendor:sdl3/image"

init_player_entity :: proc(player: ^Entity, texture: ^^sdl.Texture) {
    player.texture = texture
    //sdl.SetTextureScaleMode(player.texture^, sdl.ScaleMode.NEAREST)

    // This is particular to the loaded image for the player. Must be changed manually
    player.texture_src_position = { 0, 0 }
    player.texture_src_size = { 219, 330 }

    // This is also particular. Should generally keep aspect ratio same as the actual texture src
    // Doesn't have to be exact. In fact, a sprite that is bigger than its hitbox is ideal
    player.texture_dest_size = { 40, 60 }
    // Setting this to the negative of half the dest texture size makes it so that the texture is drawn with the players real position in the center
    player.texture_dest_offset = { -20, -45 }

    // Starting position. Should be manually overwritten by level manager
    player.position = { 100, 300 }
    player.velocity = { 0, 0 }
    player.acceleration = { 0, 0 }

    player.move_velocity = { 0, 0 }
    player.move_acceleration = { 0, 0 }

    player.is_walking = false

    player.walk_speed = 200
    player.run_speed = 400

    player.jump_height = 200
    player.jump_duration = 1

    // Again, should be manually finetuned
    init_hitbox(&player.combat_hitbox, -12, -12, 25, 25, &player.position, .COMBAT)
    init_hitbox(&player.collision_hitbox, -15, -15, 30, 30, &player.position, .COLLISION)

    player.collision_tier = 0
}

handle_player_input_keydown :: proc(player: ^Entity, scan_code: sdl.Scancode, key_code: sdl.Keycode) {
    #partial switch scan_code {
        case .W:
            player.move_velocity.y -= 1
        case .S:
            player.move_velocity.y += 1
        case .A:
            player.move_velocity.x -= 1
        case .D:
            player.move_velocity.x += 1
    }

    switch key_code {
        case sdl.K_LSHIFT:
            player.is_walking = true
    }
}

handle_player_input_keyup :: proc(player: ^Entity, scan_code: sdl.Scancode, key_code: sdl.Keycode) {
    #partial switch scan_code {
        case .W:
            player.move_velocity.y += 1
        case .S:
            player.move_velocity.y -= 1
        case .A:
            player.move_velocity.x += 1
        case .D:
            player.move_velocity.x -= 1
    }

    switch key_code {
        case sdl.K_LSHIFT:
            player.is_walking = false
    }
}

update_player_entity :: proc(player: ^Entity, tmap: TileMap, tinfo: TileInfo, dt: f32) {
    move_velocity := player.move_velocity
    //move_velocity.y = 0
    if player.is_walking { move_velocity.x *= player.walk_speed }
    else { move_velocity.x *= player.run_speed }

    move_velocity.y *= player.run_speed

    if move_velocity.x > 0 {
        player.facing_right = true
    } else if move_velocity.x < 0 {
        player.facing_right = false
    }

    update_velocity := player.velocity + move_velocity
    update_acceleration := player.acceleration + player.move_acceleration

    update_velocity += update_acceleration * dt

    old_position := player.position

    player.position += update_velocity * dt

    update_hitbox(&player.collision_hitbox)
    update_hitbox(&player.combat_hitbox)

    player.position = tilemap_collision_correction_split_axis(player.collision_hitbox, old_position, player.position, update_velocity * dt, tmap, tinfo, player.collision_tier)
}

draw_player_entity :: proc(player: Entity, tmap: ^TileMap, renderer: ^sdl.Renderer) {
    sdl.SetRenderDrawColor(renderer, 255, 255, 255, sdl.ALPHA_OPAQUE)

    player := player

    //round_decimals(&player.position.x, &player.position.y)

    texture_dest_size := player.texture_dest_size
    texture_dest_offset := player.texture_dest_offset

    if player.facing_right {
        texture_dest_size.x *= -1
        texture_dest_offset.x *= -1
    }

    src_rect := sdl.FRect{
        player.texture_src_position.x, player.texture_src_position.y,
        player.texture_src_size.x, player.texture_src_size.y,
    }

    dest_rect := sdl.FRect{
        player.position.x + texture_dest_offset.x, player.position.y + texture_dest_offset.y,
        texture_dest_size.x, texture_dest_size.y,
    }

    sdl.RenderTexture(renderer, player.texture^, &src_rect, &dest_rect)

    position_rect := sdl.FRect{ player.position.x - 3, player.position.y - 3, 6, 6 }

    // debug player real position
    sdl.SetRenderDrawColor(renderer, 0, 0, 255, sdl.ALPHA_OPAQUE)
    sdl.RenderFillRect(renderer, &position_rect)

    // debug player hitbox
    draw_hitbox(player.combat_hitbox, renderer)
    draw_hitbox(player.collision_hitbox, renderer)

    // debug occupied tiles
    occupied := make([dynamic]Vector2u)
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
}

set_player_position_grid :: proc(player: ^Entity, pos: Vector2u, g_size: u32) {
    set_pos := Vector2f{ cast(f32) (pos.x * g_size + g_size / 2), cast(f32) (pos.y * g_size + g_size / 2)}
    player.position = set_pos
}
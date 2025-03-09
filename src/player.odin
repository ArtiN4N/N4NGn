package main

import "core:fmt"
import "core:os"
import "core:strings"
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
    player.combat_hitbox = {
        position = { -12, -12 },
        size = { 25, 25 },
        anchor = &player.position,
        type = .COMBAT
    }

    player.collision_hitbox = {
        position = { -15, -15 },
        size = { 30, 30 },
        anchor = &player.position,
        type = .COLLISION
    }

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

update_player_entity :: proc(player: ^Entity, dt: f32) {
    move_velocity := player.move_velocity
    move_velocity.y = 0
    if player.is_walking { move_velocity.x *= player.walk_speed }
    else { move_velocity.x *= player.run_speed }

    if move_velocity.x > 0 {
        player.facing_right = true
    } else if move_velocity.x < 0 {
        player.facing_right = false
    }

    update_velocity := player.velocity + move_velocity
    update_acceleration := player.acceleration + player.move_acceleration

    player.velocity += update_acceleration * dt
    player.position += update_velocity * dt
}

draw_player_entity :: proc(player: Entity, renderer: ^sdl.Renderer) {
    sdl.SetRenderDrawColor(renderer, 255, 255, 255, sdl.ALPHA_OPAQUE)

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
}
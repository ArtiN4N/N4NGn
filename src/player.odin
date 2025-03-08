package main

import "core:fmt"
import "core:os"
import "core:strings"
import sdl "vendor:sdl3"
import img "vendor:sdl3/image"

Vector2f :: [2]f32

Hitbox :: struct {
    position: Vector2f,
    size: Vector2f,
    anchor: ^Vector2f, // can be nil
}

hitbox_to_frect :: proc(hitbox: Hitbox) -> sdl.FRect {
    x := hitbox.position.x
    y := hitbox.position.x

    if hitbox.anchor != nil {
        x += hitbox.anchor.x
        y += hitbox.anchor.y
    }

    return sdl.FRect{ 
        x, y,
        hitbox.size.x, hitbox.size.y
    }
}

Entity :: struct {
    texture: ^^sdl.Texture,
    texture_src_position: Vector2f,
    texture_src_size: Vector2f,
    texture_dest_offset: Vector2f,
    texture_dest_size: Vector2f,

    // position is in the centre of hitbox
    position: Vector2f,
    velocity: Vector2f,
    acceleration: Vector2f,

    move_velocity: Vector2f,
    move_acceleration: Vector2f,

    is_walking: bool,

    walk_speed: f32,
    run_speed: f32,

    jump_height: f32,
    jump_duration: f32,

    hitbox: Hitbox
}

init_player_entity :: proc(player: ^Entity, texture: ^^sdl.Texture) {
    player.texture = texture
    sdl.SetTextureScaleMode(player.texture^, sdl.ScaleMode.NEAREST)

    player.texture_src_position = { 0, 0 }
    player.texture_src_size = { 219, 330 }
    player.texture_dest_size = { 110, 165 }
    player.texture_dest_offset = player.texture_dest_size / -2.0

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

    player.hitbox = {
        { 0, 0 }, { 90, 180 }, &player.position
    }
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

    if (move_velocity.x > 0 && player.texture_dest_size.x > 0) ||
    (move_velocity.x < 0 && player.texture_dest_size.x < 0) {
        player.texture_dest_size.x *= -1
        player.texture_dest_offset.x *= -1
    }

    update_velocity := player.velocity + move_velocity
    update_acceleration := player.acceleration + player.move_acceleration

    player.velocity += update_acceleration * dt
    player.position += update_velocity * dt
}

draw_player_entity :: proc(player: ^Entity, renderer: ^sdl.Renderer) {
    sdl.SetRenderDrawColor(renderer, 255, 255, 255, sdl.ALPHA_OPAQUE)
    src_rect := sdl.FRect{
        player.texture_src_position.x, player.texture_src_position.y,
        player.texture_src_size.x, player.texture_src_size.y,
    }

    dest_rect := sdl.FRect{
        player.position.x + player.texture_dest_offset.x, player.position.y + player.texture_dest_offset.y,
        player.texture_dest_size.x, player.texture_dest_size.y,
    }

    sdl.RenderTexture(renderer, player.texture^, &src_rect, &dest_rect)

    position_rect := sdl.FRect{ player.position.x - 3, player.position.y - 3, 6, 6 }
    sdl.SetRenderDrawColor(renderer, 255, 0, 0, sdl.ALPHA_OPAQUE)
    sdl.RenderFillRect(renderer, &position_rect)
}
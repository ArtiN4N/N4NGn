package main

import "core:fmt"
import "core:os"
import "core:strings"
import sdl "vendor:sdl3"
import img "vendor:sdl3/image"

HitboxType :: enum{ COMBAT, COLLISION }

Hitbox :: struct {
    position: Vector2f,
    size: Vector2f,
    anchor: ^Vector2f, // can be nil
    type: HitboxType
}

hitbox_to_frect :: proc(hitbox: Hitbox) -> sdl.FRect {
    x := hitbox.position.x
    y := hitbox.position.y

    if hitbox.anchor != nil {
        x += hitbox.anchor.x
        y += hitbox.anchor.y
    }

    return sdl.FRect{ 
        x, y,
        hitbox.size.x, hitbox.size.y
    }
}

draw_hitbox :: proc(hitbox: Hitbox, renderer: ^sdl.Renderer) {
    r, g, b : u8 = 0, 0, 0
    switch hitbox.type {
    case .COMBAT:
        r = 255
    case .COLLISION:
        b = 255
    }

    sdl.SetRenderDrawColor(renderer, r, g, b, sdl.ALPHA_OPAQUE)

    box := hitbox_to_frect(hitbox)
    sdl.RenderRect(renderer, &box)
}
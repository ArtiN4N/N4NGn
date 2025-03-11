package main

import "core:fmt"
import "core:os"
import "core:strings"
import sdl "vendor:sdl3"
import img "vendor:sdl3/image"

HitboxType :: enum{ COMBAT, COLLISION }

Corners :: enum{ NW = 0, NE, SE, SW }

Hitbox :: struct {
    position: Vector2f,
    size: Vector2f,
    anchor: ^Vector2f, // can be nil
    type: HitboxType,
    corners: [Corners]Vector2f,
}

init_hitbox :: proc(hb: ^Hitbox, x, y, w, h: f32, anchor: ^Vector2f, type: HitboxType) {
    hb.position = Vector2f{ x, y }
    hb.size = Vector2f{ w, h }
    hb.anchor = anchor
    hb.type = type

    hb.corners = {
        .NW = Vector2f{ x, y },
        .NE = Vector2f{ x + w, y },
        .SE = Vector2f{ x + w, y + h },
        .SW = Vector2f{ x, y + h },
    }
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

update_hitbox :: proc(hitbox: ^Hitbox) {
    x := hitbox.position.x
    y := hitbox.position.y
    w := hitbox.size.x
    h := hitbox.size.y

    if hitbox.anchor != nil {
        x += hitbox.anchor.x
        y += hitbox.anchor.y
    }

    hitbox.corners = {
        .NW = Vector2f{ x, y },
        .NE = Vector2f{ x + w, y },
        .SE = Vector2f{ x + w, y + h },
        .SW = Vector2f{ x, y + h },
    }
}

hitbox_corners_with_position :: proc(hitbox: Hitbox, position: Vector2f) -> [Corners]Vector2f {
    x := hitbox.position.x + position.x
    y := hitbox.position.y + position.y
    w := hitbox.size.x
    h := hitbox.size.y

    return [Corners]Vector2f{
        .NW = Vector2f{ x, y },
        .NE = Vector2f{ x + w, y },
        .SE = Vector2f{ x + w, y + h },
        .SW = Vector2f{ x, y + h },
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

    round_decimals(&box.x, &box.y)

    sdl.RenderRect(renderer, &box)
}
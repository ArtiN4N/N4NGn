package main

import "core:fmt"
import "core:os"
import "core:strings"
import sdl "vendor:sdl3"
import img "vendor:sdl3/image"

HitboxType :: enum{ COMBAT, COLLISION, GRAB }

Hitbox :: struct {
    position: sdl.Point,
    size: sdl.Point,
    anchor: ^sdl.Point, // can be nil
    type: HitboxType,
    corners: [RectangleCorners]sdl.Point,
    lines: [RectangleLines]Line,
    last_facing_right: bool,
}

init_hitbox :: proc(hb: ^Hitbox, x, y, w, h: i32, anchor: ^sdl.Point, type: HitboxType) {
    hb.position = sdl.Point{ x, y }
    hb.size = sdl.Point{ w, h }
    hb.anchor = anchor
    hb.type = type
    hb.last_facing_right = true

    hb.corners = {
        .NW = sdl.Point{ x, y },
        .NE = sdl.Point{ x + w, y },
        .SE = sdl.Point{ x + w, y + h },
        .SW = sdl.Point{ x, y + h },
    }
}

hitbox_to_rect :: proc(hitbox: Hitbox) -> sdl.Rect {
    x := hitbox.position.x
    y := hitbox.position.y

    if hitbox.anchor != nil {
        x += hitbox.anchor.x
        y += hitbox.anchor.y
    }

    return sdl.Rect{ 
        x, y,
        hitbox.size.x, hitbox.size.y
    }
}

update_hitbox :: proc(hitbox: ^Hitbox, facing_right: bool = true) {
    if !facing_right && hitbox.last_facing_right {
        hitbox.last_facing_right = false
        hitbox.position.x *= -1
    } else if facing_right && !hitbox.last_facing_right {
        hitbox.last_facing_right = true
        hitbox.position.x *= -1
    }
    x := hitbox.position.x
    y := hitbox.position.y
    w := hitbox.size.x
    h := hitbox.size.y

    if hitbox.anchor != nil {
        x += hitbox.anchor.x
        y += hitbox.anchor.y
    }

    hitbox.corners = {
        .NW = sdl.Point{ x, y },
        .NE = sdl.Point{ x + w, y },
        .SE = sdl.Point{ x + w, y + h },
        .SW = sdl.Point{ x, y + h },
    }
}

hitbox_corners_with_iposition :: proc(hitbox: Hitbox, position: sdl.Point, facing_right: bool = true) -> [RectangleCorners]sdl.Point {
    h_pos_x := hitbox.position.x

    if !facing_right {
        h_pos_x *= -1
    }

    x := h_pos_x + position.x
    y := hitbox.position.y + position.y
    w := hitbox.size.x
    h := hitbox.size.y

    return [RectangleCorners]sdl.Point{
        .NW = sdl.Point{ x, y },
        .NE = sdl.Point{ x + w, y },
        .SE = sdl.Point{ x + w, y + h },
        .SW = sdl.Point{ x, y + h },
    }
}

hitbox_corners_with_fposition :: proc(hitbox: Hitbox, position: sdl.FPoint, facing_right: bool = true) -> [RectangleCorners]sdl.FPoint {
    h_pos_x := hitbox.position.x

    if !facing_right {
        h_pos_x *= -1
    }

    x := cast(f32) h_pos_x + position.x
    y := cast(f32) hitbox.position.y + position.y
    w := cast(f32) hitbox.size.x
    h := cast(f32) hitbox.size.y

    return [RectangleCorners]sdl.FPoint{
        .NW = sdl.FPoint{ x, y },
        .NE = sdl.FPoint{ x + w, y },
        .SE = sdl.FPoint{ x + w, y + h },
        .SW = sdl.FPoint{ x, y + h },
    }
}

draw_hitbox :: proc(hitbox: Hitbox, renderer: ^sdl.Renderer) {
    r, g, b : u8 = 0, 0, 0
    switch hitbox.type {
    case .COMBAT:
        r = 255
    case .COLLISION:
        b = 255
    case .GRAB:
        g = 255
    }

    sdl.SetRenderDrawColor(renderer, r, g, b, sdl.ALPHA_OPAQUE)

    box := hitbox_to_rect(hitbox)

    //round_decimals(&box.x, &box.y)

    // note: move this to camera
    //sdl.RenderRect(renderer, &box)
}
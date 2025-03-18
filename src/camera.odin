package main

import "core:fmt"
import "core:os"
import "core:strings"
import sdl "vendor:sdl3"

// A camera has a view of the game's logic space.
// It keeps a pointer to a vector as its anchor. This anchor is the center of the camera.
// The cameras view is a source rectangle, using the sum of its source offset as its position,
// and its source size as its size.
Camera :: struct {
    size: sdl.Point,
    offset: sdl.Point,
    anchor: ^sdl.Point
}

// By default, the offset of the camera is the negative of half its size.
// Logically, this means the camera's anchor is in the center of the camera.
// A custom offset can be applied, which is added on top of this default size-based offset.
create_camera :: proc(width, height: i32, anchor: ^sdl.Point, offset: sdl.Point = POINT_ZERO) -> (camera: Camera) {
    camera.size = { width, height }
    camera.offset = { -width / 2, -height / 2 } + offset
    camera.anchor = anchor

    log("Created camera.")

    return
}

get_camera_real_position :: proc(cam: Camera) -> sdl.Point {
    return cam.offset + cam.anchor^
}

get_camera_real_rectangle :: proc(cam: Camera) -> sdl.Rect {
    pos := get_camera_real_position(cam)
    return sdl.Rect{ pos.x, pos.y, cam.size.x, cam.size.y}
}

is_point_in_camera :: proc(cam: Camera, pos: sdl.Point) -> bool {
    rect := get_camera_real_rectangle(cam)
    return sdl.PointInRect(pos, rect)
}

is_rectangle_in_camera :: proc(cam: Camera, rect: sdl.Rect) -> bool {
    points := get_rectangle_points(rect)
    
    return sdl.GetRectEnclosingPoints(raw_data(&points), 4, get_camera_real_rectangle(cam), nil)
}

// Does an offset to the texture to be drawn before rendering, translating it into the screen.
// Texture is drawn as if there is an actual camera moving around the logical world.
render_texture_via_camera :: proc(cam: Camera, renderer: ^sdl.Renderer, tex: ^sdl.Texture, tex_src, tex_dest: ^sdl.Rect) {
    tex_src, tex_dest := tex_src, tex_dest

    real_pos := get_camera_real_position(cam)
    rect_add_point(tex_dest, -real_pos)

    fsrc := sdl.FRect{}
    fdest := sdl.FRect{}

    draw_src : ^sdl.FRect = nil
    draw_dest : ^sdl.FRect = nil

    if tex_src != nil {
        fsrc = rect_to_frect(tex_src^)
        draw_src = &fsrc
    }
    if tex_dest != nil {
        fdest = rect_to_frect(tex_dest^)
        draw_dest = &fdest
    }

    sdl.RenderTexture(renderer, tex, draw_src, draw_dest)
}

package main

import sdl "vendor:sdl3"
import "core:math"
import "core:fmt"

TilePoint :: [2]u32

POINT_ZERO :: sdl.Point{0,0}
FPOINT_ZERO :: sdl.FPoint{0,0}

RectangleCorners :: enum{ NW = 0, NE, SE, SW }
RectangleLines :: enum{ NO = 0, EA, SO, WE }

get_rectangle_points :: proc(rect: sdl.Rect) -> [RectangleCorners]sdl.Point {
    return {
        .NW = { rect.x, rect.y },
        .NE = { rect.x + rect.w - 1, rect.y },
        .SE = { rect.x + rect.w - 1, rect.y + rect.h - 1 },
        .SW = { rect.x, rect.y + rect.h - 1 },
    }
}

rect_add_point :: proc(rect: ^sdl.Rect, point: sdl.Point) {
    rect.x += point.x
    rect.y += point.y
}

Line :: struct {
    p1: sdl.Point,
    p2: sdl.Point,
}

FLine :: struct {
    p1: sdl.FPoint,
    p2: sdl.FPoint,
}

rect_to_frect :: proc(r: sdl.Rect) -> sdl.FRect {
    return sdl.FRect{ cast(f32) r.x, cast(f32) r.y, cast(f32) r.w, cast(f32) r.h }
}

fpoint_to_point :: proc(fp: sdl.FPoint) -> sdl.Point {
    return { cast(i32) fp.x, cast(i32) fp.y }
}

normalize_pointf :: proc(vec: sdl.FPoint) -> sdl.FPoint {
    len := math.sqrt(math.pow(vec.x, 2) + math.pow(vec.y, 2))
    return vec / len
}

pointi_dist :: proc(p1, p2: sdl.Point) -> f32 {
    return math.sqrt(math.pow(cast(f32) (p2.x - p1.x), 2) + math.pow(cast(f32)  (p2.y - p1.y), 2))
}

pointf_dist :: proc(p1, p2: sdl.FPoint) -> f32 {
    return math.sqrt(math.pow(p2.x - p1.x, 2) + math.pow(p2.y - p1.y, 2))
}

point_dist :: proc{ pointi_dist, pointf_dist }

vectori_cross :: proc(a, b: sdl.Point) -> i32 {
    return a.x*b.y - b.x*a.y
}

vectorf_cross :: proc(a, b: sdl.FPoint) -> f32 {
    return a.x*b.y - b.x*a.y
}

vector_cross :: proc{ vectori_cross, vectorf_cross }

line_collide_line_i :: proc(line1, line2: Line) -> bool {
    q := line1.p1
    s := line1.p2 - q
    p := line2.p1
    r := line2.p2 - p

    denom := vector_cross(r, s)

    t := vector_cross(q - p, s) / denom
    u := vector_cross(q - p, r) / denom

    return (0 <= t && t <= 1) && (0 <= u && u <= 1)
}

line_collide_line_f :: proc(line1, line2: FLine) -> bool {
    q := line1.p1
    s := line1.p2 - q
    p := line2.p1
    r := line2.p2 - p

    denom := vector_cross(r, s)

    t := vector_cross(q - p, s) / denom
    u := vector_cross(q - p, r) / denom

    return (0 <= t && t <= 1) && (0 <= u && u <= 1)

}

line_collide_line :: proc{ line_collide_line_i, line_collide_line_f }

round_decimals :: proc(decs : ..^f32) {
    for &dec in decs {
        dec^ = cast(f32) (cast(int) dec^)
    }
}
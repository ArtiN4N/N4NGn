package main

import "core:math"
import "core:fmt"

Vector2f :: [2]f32
Vector2i :: [2]i32
Vector2u :: [2]u32

linef :: struct {
    p1: Vector2f,
    p2: Vector2f
}

normalize_vectorf :: proc(vec: Vector2f) -> Vector2f {
    len := math.sqrt(math.pow(vec.x, 2) + math.pow(vec.y, 2))
    return vec / len
}

vectorf_dist :: proc(p1, p2: Vector2f) -> f32 {
    return math.sqrt(math.pow(p2.x - p1.x, 2) + math.pow(p2.y - p1.y, 2))
}

cross_vectorf :: proc(a, b: Vector2f) -> f32 {
    return a.x*b.y - b.x*a.y
}

line_collide_line :: proc(line1, line2: linef) -> bool {
    q := line1.p1
    s := line1.p2 - q
    p := line2.p1
    r := line2.p2 - p

    denom := cross_vectorf(r, s)

    t := cross_vectorf(q - p, s) / denom
    u := cross_vectorf(q - p, r) / denom

    return (0 <= t && t <= 1) && (0 <= u && u <= 1)
}

round_decimals :: proc(decs : ..^f32) {
    for &dec in decs {
        dec^ = cast(f32) (cast(int) dec^)
    }
}
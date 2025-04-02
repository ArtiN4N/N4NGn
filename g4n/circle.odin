package g4n
import sdl "vendor:sdl3"
import "core:math"

ICircle :: struct { x, y, r: i32 }
FCircle :: struct { x, y, r: f32 }
TCircle :: struct { x, y, r: u32 }



icircle_to_fcircle :: proc(a: ICircle) -> (c: FCircle) {
    c.x = f32(a.x)
    c.y = f32(a.y)
    c.r = f32(a.r)

    return
}
tcircle_to_fcircle :: proc(a: TCircle) -> (c: FCircle) {
    c.x = f32(a.x)
    c.y = f32(a.y)
    c.r = f32(a.r)

    return
}

to_fcircle :: proc{icircle_to_fcircle, tcircle_to_fcircle}




icircle_to_tcircle :: proc(a: ICircle) -> (c: TCircle) {
    if a.x < 0 || a.y < 0 || a.r < 0 {
        log("Uh oh! Casting negative int to unsigned int!")
    }

    c.x = u32(a.x)
    c.y = u32(a.y)
    c.r = u32(a.r)

    return
}
fcircle_to_tcircle :: proc(a: FCircle) -> (c: TCircle) {
    if a.x < 0 || a.y < 0 || a.r < 0 {
        log("Uh oh! Casting negative int to unsigned int!")
    }

    c.x = u32(a.x)
    c.y = u32(a.y)
    c.r = u32(a.r)

    return
}

to_tcircle :: proc{icircle_to_tcircle, fcircle_to_tcircle}




tcircle_to_icircle :: proc(a: TCircle) -> (c: ICircle) {
    c.x = i32(a.x)
    c.y = i32(a.y)
    c.r = i32(a.r)

    return
}
fcircle_to_icircle :: proc(a: FCircle) -> (c: ICircle) {
    c.x = i32(a.x)
    c.y = i32(a.y)
    c.r = i32(a.r)

    return
}

to_icircle :: proc{tcircle_to_icircle, fcircle_to_icircle}




get_icircle_position :: proc(c: ICircle) -> IVector {
    return { c.x, c.y }
}

get_fcircle_position :: proc(c: FCircle) -> FVector {
    return { c.x, c.y }
}

get_tcircle_position :: proc(c: TCircle) -> TVector {
    return { c.x, c.y }
}

get_circle_position :: proc{get_icircle_position, get_fcircle_position, get_tcircle_position}




icircle_cumf :: proc(c: ICircle) -> f32 {
    return 2 * math.PI * f32(c.r)
}
fcircle_cumf :: proc(c: FCircle) -> f32 {
    return 2 * math.PI * c.r
}
tcircle_cumf :: proc(c: TCircle) -> f32 {
    return 2 * math.PI * f32(c.r)
}
get_circle_circumfrence :: proc{icircle_cumf, fcircle_cumf, tcircle_cumf}




icircle_add_vector :: proc(a: ICircle, b: IVector) -> ICircle {
    return {a.x + b.x, a.y + b.y, a.r}
}
fcircle_add_vector :: proc(a: FCircle, b: FVector) -> FCircle {
    return {a.x + b.x, a.y + b.y, a.r}
}
tcircle_add_vector :: proc(a: TCircle, b: TVector) -> TCircle {
    return {a.x + b.x, a.y + b.y, a.r}
}

// Circle type dominates
circle_add_vector :: proc{icircle_add_vector, fcircle_add_vector, tcircle_add_vector}




icircle_vector_dist :: proc(a: ICircle, b: IVector) -> f32 {
    return max(vector_dist(b, get_circle_position(a)) - f32(a.r), 0)
}
fcircle_vector_dist :: proc(a: FCircle, b: FVector) -> f32 {
    return max(vector_dist(b, get_circle_position(a)) - a.r, 0)
}
tcircle_vector_dist :: proc(a: TCircle, b: TVector) -> f32 {
    return max(vector_dist(b, get_circle_position(a)) - f32(a.r), 0)
}

circle_vector_dist :: proc{icircle_vector_dist, fcircle_vector_dist, tcircle_vector_dist}




icircles_collide :: proc(a: ICircle, b: ICircle) -> bool {
    return vector_dist(get_circle_position(a), get_circle_position(b)) <= f32(a.r + b.r)
}
fcircles_collide :: proc(a: FCircle, b: FCircle) -> bool {
    return vector_dist(get_circle_position(a), get_circle_position(b)) <= a.r + b.r
}
tcircles_collide :: proc(a: TCircle, b: TCircle) -> bool {
    return vector_dist(get_circle_position(a), get_circle_position(b)) <= f32(a.r + b.r)
}

circles_collide :: proc{icircles_collide, fcircles_collide, tcircles_collide}




icircle_rect_dist :: proc(a: ICircle, b: IRect) -> f32 {
    rc := get_rect_corners(b)

    test_x := a.x
    test_y := a.y

    if a.x < rc[.NW].x { test_x = rc[.NW].x }
    else if a.x > rc[.NE].x { test_x = rc[.NE].x }

    if a.y < rc[.NE].y { test_y = rc[.NE].y }
    else if a.y > rc[.SE].y { test_y = rc[.SE].y }

    d_x := a.x - test_x
    d_y := a.y - test_y
    return max(0, vector_dist(IVector{d_x, d_y}, IVECTOR_ZERO) - f32(a.r))
}
fcircle_rect_dist :: proc(a: FCircle, b: FRect) -> f32 {
    rc := get_rect_corners(b)

    test_x := a.x
    test_y := a.y

    if a.x < rc[.NW].x { test_x = rc[.NW].x }
    else if a.x > rc[.NE].x { test_x = rc[.NE].x }

    if a.y < rc[.NE].y { test_y = rc[.NE].y }
    else if a.y > rc[.SE].y { test_y = rc[.SE].y }

    d_x := a.x - test_x
    d_y := a.y - test_y
    return max(0, vector_dist(FVector{d_x, d_y}, FVECTOR_ZERO) - a.r)
}
tcircle_rect_dist :: proc(a: TCircle, b: TRect) -> f32 {
    rc := get_rect_corners(b)

    test_x := a.x
    test_y := a.y

    if a.x < rc[.NW].x { test_x = rc[.NW].x }
    else if a.x > rc[.NE].x { test_x = rc[.NE].x }

    if a.y < rc[.NE].y { test_y = rc[.NE].y }
    else if a.y > rc[.SE].y { test_y = rc[.SE].y }

    d_x := i32(a.x) - i32(test_x)
    d_y := i32(a.y) - i32(test_y)

    return max(0, vector_dist(IVector{d_x, d_y}, IVECTOR_ZERO) - f32(a.r))
}

circle_rect_dist :: proc{icircle_rect_dist, fcircle_rect_dist, tcircle_rect_dist}


// circle collides rect
icircle_collides_rect :: proc(a: ICircle, b: IRect) -> bool {
    return circle_rect_dist(a, b) <= 0
}

fcircle_collides_rect :: proc(a: FCircle, b: FRect) -> bool {
    return circle_rect_dist(a, b) <= 0
}

tcircle_collides_rect :: proc(a: TCircle, b: TRect) -> bool {
    return circle_rect_dist(a, b) <= 0
}

circle_collides_rect :: proc{icircle_collides_rect, fcircle_collides_rect, tcircle_collides_rect}
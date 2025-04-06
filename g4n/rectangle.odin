package g4n
import sdl "vendor:sdl3"
import "core:math"

// Rectangle positions are in the center of the rectangle

IRect :: sdl.Rect
FRect :: sdl.FRect
TRect :: struct { x, y, w, h: u32 }

IRECT_ZERO :: IRect{0,0,0,0}
FRECT_ZERO :: FRect{0,0,0,0}
TRECT_ZERO :: TRect{0,0,0,0}

RectCornerNames :: enum{ NW = 0, NE, SE, SW }
RectLineNames :: enum{ NO = 0, EA, SO, WE }

IRectCorners :: [RectCornerNames]IVector
IRectLines   :: [RectLineNames]ILine

FRectCorners :: [RectCornerNames]FVector
FRectLines   :: [RectLineNames]FLine

TRectCorners :: [RectCornerNames]TVector
TRectLines   :: [RectLineNames]TLine


irect_to_frect :: proc(a: IRect) -> (r: FRect) {
    r.x = f32(a.x)
    r.y = f32(a.y)
    r.w = f32(a.w)
    r.h = f32(a.h)

    return
}
trect_to_frect :: proc(a: TRect) -> (r: FRect) {
    r.x = f32(a.x)
    r.y = f32(a.y)
    r.w = f32(a.w)
    r.h = f32(a.h)

    return
}

to_frect :: proc{irect_to_frect, trect_to_frect}




irect_to_trect :: proc(a: IRect) -> (r: TRect) {
    if a.x < 0 || a.y < 0 || a.w < 0 || a.h < 0 {
        log("Uh oh! Casting negative int to unsigned int!")
    }

    r.x = u32(a.x)
    r.y = u32(a.y)
    r.w = u32(a.w)
    r.h = u32(a.h)

    return
}
frect_to_trect :: proc(a: FRect) -> (r: TRect) {
    if a.x < 0 || a.y < 0 || a.w < 0 || a.h < 0 {
        log("Uh oh! Casting negative int to unsigned int!")
    }

    r.x = u32(a.x)
    r.y = u32(a.y)
    r.w = u32(a.w)
    r.h = u32(a.h)

    return
}

to_trect :: proc{irect_to_trect, frect_to_trect}




trect_to_irect :: proc(a: TRect) -> (r: IRect) {
    r.x = i32(a.x)
    r.y = i32(a.y)
    r.w = i32(a.w)
    r.h = i32(a.h)

    return
}
frect_to_irect :: proc(a: FRect) -> (r: IRect) {
    r.x = i32(a.x)
    r.y = i32(a.y)
    r.w = i32(a.w)
    r.h = i32(a.h)

    return
}

to_irect :: proc{trect_to_irect, frect_to_irect}


toi_sdl_frect :: proc(r: IRect) -> sdl.FRect {
    return sdl.FRect{f32(r.x), f32(r.y), f32(r.w), f32(r.h)}
}
tof_sdl_frect :: proc(r: FRect) -> sdl.FRect {
    return sdl.FRect{r.x, r.y, r.w, r.h}
}
to_sdl_frect :: proc{toi_sdl_frect, tof_sdl_frect}


irect_from_nw_se :: proc(nw, se: IVector) -> IRect {
    w := se.x - nw.x + 1
    h := se.y - nw.y + 1

    half_w := i32(math.floor(f32(w - 1) / 2))
    half_h := i32(math.floor(f32(h - 1) / 2))

    return IRect{nw.x + half_w, nw.y + half_h, w, h}
}
frect_from_nw_se :: proc(nw, se: FVector) -> FRect {
    w := se.x - nw.x + 1
    h := se.y - nw.y + 1

    return FRect{nw.x + (w-1) / 2, nw.y + (h-1) / 2, w, h}
}
trect_from_nw_se :: proc(nw, se: TVector) -> TRect {
    w := se.x - nw.x + 1
    h := se.y - nw.y + 1

    half_w := u32(math.floor(f32(w - 1) / 2))
    half_h := u32(math.floor(f32(h - 1) / 2))

    return TRect{nw.x + half_w, nw.y + half_h, w, h}
}
rect_from_nw_se :: proc{irect_from_nw_se, frect_from_nw_se, trect_from_nw_se}




irect_with_position :: proc(r: IRect, p: IVector) -> IRect {
    return { p.x, p.y, r.w, r.h }
}

frect_with_position :: proc(r: FRect, p: FVector) -> FRect {
    return { p.x, p.y, r.w, r.h }
}

trect_with_position :: proc(r: TRect, p: TVector) -> TRect {
    return { p.x, p.y, r.w, r.h }
}

rect_with_position :: proc{irect_with_position, frect_with_position, trect_with_position}




get_irect_position :: proc(r: IRect) -> IVector {
    return { r.x, r.y }
}

get_frect_position :: proc(r: FRect) -> FVector {
    return { r.x, r.y }
}

get_trect_position :: proc(r: TRect) -> TVector {
    return { r.x, r.y }
}

get_rect_position :: proc{get_irect_position, get_frect_position, get_trect_position}




irect_size :: proc(r: IRect) -> IVector {
    return { r.w, r.h }
}
frect_size :: proc(r: FRect) -> FVector {
    return { r.w, r.h }
}
trect_size :: proc(r: TRect) -> TVector {
    return { r.w, r.h }
}
get_rect_size :: proc{irect_size, frect_size, trect_size}




irect_add_vector :: proc(a: IRect, b: IVector) -> (r: IRect) {
    r = {a.x + b.x, a.y + b.y, a.w, a.h}
    return
}
frect_add_vector :: proc(a: FRect, b: FVector) -> (r: FRect) {
    r = {a.x + b.x, a.y + b.y, a.w, a.h}
    return
}
trect_add_vector :: proc(a: TRect, b: TVector) -> (r: TRect) {
    r = {a.x + b.x, a.y + b.y, a.w, a.h}
    return
}

// Rect type dominates
rect_add_vector :: proc{irect_add_vector, frect_add_vector, trect_add_vector}




get_irect_corners :: proc(r: IRect) -> IRectCorners {
    // width includes the first pixel, hence the - 1
    fl_half_width  := math.floor(f32(r.w - 1) / 2)
    ce_half_width  := math.ceil( f32(r.w - 1) / 2)
    fl_half_height := math.floor(f32(r.h - 1) / 2)
    ce_half_height := math.ceil( f32(r.h - 1) / 2)
    return {
        .NW = { r.x - i32(fl_half_width), r.y - i32(fl_half_height) },
        .NE = { r.x + i32(ce_half_width), r.y - i32(fl_half_height) },
        .SE = { r.x + i32(ce_half_width), r.y + i32(ce_half_height) },
        .SW = { r.x - i32(fl_half_width), r.y + i32(ce_half_height) },
    }
}

get_frect_corners :: proc(r: FRect) -> FRectCorners {
    // width includes the first pixel, hence the - 1
    fl_half_width  := (r.w - 1) / 2
    ce_half_width  := (r.w - 1) / 2
    fl_half_height := (r.h - 1) / 2
    ce_half_height := (r.h - 1) / 2
    return {
        .NW = { r.x - fl_half_width, r.y - fl_half_height },
        .NE = { r.x + ce_half_width, r.y - fl_half_height },
        .SE = { r.x + ce_half_width, r.y + ce_half_height },
        .SW = { r.x - fl_half_width, r.y + ce_half_height },
    }
}

get_trect_corners :: proc(r: TRect) -> TRectCorners {
    // width includes the first pixel, hence the - 1
    fl_half_width  := math.floor(f32(r.w - 1) / 2)
    ce_half_width  := math.ceil( f32(r.w - 1) / 2)
    fl_half_height := math.floor(f32(r.h - 1) / 2)
    ce_half_height := math.ceil( f32(r.h - 1) / 2)

    if r.w == 0 || r.h == 0 || u32(fl_half_width) > r.x || u32(fl_half_height) > r.y {
        log("Uh oh! Casting negative int to unsigned int!")
    }
    return {
        .NW = { r.x - u32(fl_half_width), r.y - u32(fl_half_height) },
        .NE = { r.x + u32(ce_half_width), r.y - u32(fl_half_height) },
        .SE = { r.x + u32(ce_half_width), r.y + u32(ce_half_height) },
        .SW = { r.x - u32(fl_half_width), r.y + u32(ce_half_height) },
    }
}

get_rect_corners :: proc{get_irect_corners, get_frect_corners, get_trect_corners}




get_irect_lines :: proc(r: IRect) -> IRectLines {
    // width includes the first pixel, hence the - 1
    fl_half_width  := math.floor(f32(r.w - 1) / 2)
    ce_half_width  := math.ceil( f32(r.w - 1) / 2)
    fl_half_height := math.floor(f32(r.h - 1) / 2)
    ce_half_height := math.ceil( f32(r.h - 1) / 2)

    p1 := IVector{ r.x - i32(fl_half_width), r.y - i32(fl_half_height) }
    p2 := IVector{ r.x + i32(ce_half_width), r.y - i32(fl_half_height) }
    p3 := IVector{ r.x + i32(ce_half_width), r.y + i32(ce_half_height) }
    p4 := IVector{ r.x - i32(fl_half_width), r.y + i32(ce_half_height) }

    return IRectLines{
        .NO = {p1, p2},
        .EA = {p2, p3},
        .SO = {p3, p4},
        .WE = {p4, p1},
    }
}

get_frect_lines :: proc(r: FRect) -> FRectLines {
    // width includes the first pixel, hence the - 1
    fl_half_width  := (r.w - 1) / 2
    ce_half_width  := (r.w - 1) / 2
    fl_half_height := (r.h - 1) / 2
    ce_half_height := (r.h - 1) / 2

    p1 := FVector{ r.x - fl_half_width, r.y - fl_half_height }
    p2 := FVector{ r.x + ce_half_width, r.y - fl_half_height }
    p3 := FVector{ r.x + ce_half_width, r.y + ce_half_height }
    p4 := FVector{ r.x - fl_half_width, r.y + ce_half_height }

    return FRectLines{
        .NO = {p1, p2},
        .EA = {p2, p3},
        .SO = {p3, p4},
        .WE = {p4, p1},
    }
}

get_trect_lines :: proc(r: TRect) -> TRectLines {
    // width includes the first pixel, hence the - 1
    fl_half_width  := math.floor(f32(r.w - 1) / 2)
    ce_half_width  := math.ceil( f32(r.w - 1) / 2)
    fl_half_height := math.floor(f32(r.h - 1) / 2)
    ce_half_height := math.ceil( f32(r.h - 1) / 2)

    p1 := TVector{ r.x - u32(fl_half_width), r.y - u32(fl_half_height) }
    p2 := TVector{ r.x + u32(ce_half_width), r.y - u32(fl_half_height) }
    p3 := TVector{ r.x + u32(ce_half_width), r.y + u32(ce_half_height) }
    p4 := TVector{ r.x - u32(fl_half_width), r.y + u32(ce_half_height) }

    if r.w == 0 || r.h == 0 || u32(fl_half_width) > r.x || u32(fl_half_height) > r.y {
        log("Uh oh! Casting negative int to unsigned int!")
    }

    return TRectLines{
        .NO = {p1, p2},
        .EA = {p2, p3},
        .SO = {p3, p4},
        .WE = {p4, p1},
    }
}

get_rect_lines :: proc{get_irect_lines, get_frect_lines, get_trect_lines}




irect_contains_vector :: proc(r: IRect, v: IVector) -> bool {
    rc := get_rect_corners(r)
    return v.x >= rc[.NW].x && v.x <= rc[.NE].x && v.y >= rc[.NE].y && v.y <= rc[.SE].y
}
frect_contains_vector :: proc(r: FRect, v: FVector) -> bool {
    rc := get_rect_corners(r)
    return v.x >= rc[.NW].x && v.x <= rc[.NE].x && v.y >= rc[.NE].y && v.y <= rc[.SE].y
}
trect_contains_vector :: proc(r: TRect, v: TVector) -> bool {
    rc := get_rect_corners(r)
    return v.x >= rc[.NW].x && v.x <= rc[.NE].x && v.y >= rc[.NE].y && v.y <= rc[.SE].y
}

rect_contains_vector :: proc{irect_contains_vector, frect_contains_vector, trect_contains_vector}




irects_collide :: proc(a, b: IRect) -> bool {
    ac := get_rect_corners(a)
    bc := get_rect_corners(b)
    return ac[.NE].x >= bc[.NW].x && ac[.NW].x <= bc[.NE].x && ac[.SE].y >= bc[.NE].y && ac[.NE].y <= bc[.SE].y
}
frects_collide :: proc(a, b: FRect) -> bool {
    ac := get_rect_corners(a)
    bc := get_rect_corners(b)
    return ac[.NE].x >= bc[.NW].x && ac[.NW].x <= bc[.NE].x && ac[.SE].y >= bc[.NE].y && ac[.NE].y <= bc[.SE].y
}
trects_collide :: proc(a, b: TRect) -> bool {
    ac := get_rect_corners(a)
    bc := get_rect_corners(b)
    return ac[.NE].x >= bc[.NW].x && ac[.NW].x <= bc[.NE].x && ac[.SE].y >= bc[.NE].y && ac[.NE].y <= bc[.SE].y
}

rects_collide :: proc{irects_collide, frects_collide, trects_collide}




irects_distance :: proc(a, b: IRect) -> f32 {
    ac := get_rect_corners(a)
    bc := get_rect_corners(b)

    b_is_left := bc[.NE].x < ac[.NW].x
    b_is_right := bc[.NW].x > ac[.NE].x
    b_is_bottom := bc[.NE].y > ac[.SE].y
    b_is_top := bc[.SE].y < ac[.NE].y

    if b_is_top && b_is_left          { return vector_dist(bc[.SE], ac[.NW]) }
    else if b_is_left && b_is_bottom  { return vector_dist(bc[.NE], ac[.SW]) }
    else if b_is_bottom && b_is_right { return vector_dist(bc[.NW], ac[.SE]) }
    else if b_is_right && b_is_top    { return vector_dist(bc[.SW], ac[.NE]) }
    else if b_is_left   { return abs(f32(bc[.NE].x) - f32(ac[.NW].x)) }
    else if b_is_right  { return abs(f32(bc[.NW].x) - f32(ac[.NE].x)) }
    else if b_is_bottom { return abs(f32(bc[.NE].y) - f32(ac[.SE].y)) }
    else if b_is_top    { return abs(f32(bc[.SE].y) - f32(ac[.NE].y)) }
    else { return 0 } // rects intersect
}
frects_distance :: proc(a, b: FRect) -> f32 {
    ac := get_rect_corners(a)
    bc := get_rect_corners(b)

    b_is_left := bc[.NE].x < ac[.NW].x
    b_is_right := bc[.NW].x > ac[.NE].x
    b_is_bottom := bc[.NE].y > ac[.SE].y
    b_is_top := bc[.SE].y < ac[.NE].y

    if b_is_top && b_is_left          { return vector_dist(bc[.SE], ac[.NW]) }
    else if b_is_left && b_is_bottom  { return vector_dist(bc[.NE], ac[.SW]) }
    else if b_is_bottom && b_is_right { return vector_dist(bc[.NW], ac[.SE]) }
    else if b_is_right && b_is_top    { return vector_dist(bc[.SW], ac[.NE]) }
    else if b_is_left   { return abs(bc[.NE].x - ac[.NW].x) }
    else if b_is_right  { return abs(bc[.NW].x - ac[.NE].x) }
    else if b_is_bottom { return abs(bc[.NE].y - ac[.SE].y) }
    else if b_is_top    { return abs(bc[.SE].y - ac[.NE].y) }
    else { return 0 } // rects intersect
}
trects_distance :: proc(a, b: TRect) -> f32 {
    ac := get_rect_corners(a)
    bc := get_rect_corners(b)

    b_is_left := bc[.NE].x < ac[.NW].x
    b_is_right := bc[.NW].x > ac[.NE].x
    b_is_bottom := bc[.NE].y > ac[.SE].y
    b_is_top := bc[.SE].y < ac[.NE].y

    if b_is_top && b_is_left          { return vector_dist(bc[.SE], ac[.NW]) }
    else if b_is_left && b_is_bottom  { return vector_dist(bc[.NE], ac[.SW]) }
    else if b_is_bottom && b_is_right { return vector_dist(bc[.NW], ac[.SE]) }
    else if b_is_right && b_is_top    { return vector_dist(bc[.SW], ac[.NE]) }
    else if b_is_left   { return abs(f32(bc[.NE].x) - f32(ac[.NW].x)) }
    else if b_is_right  { return abs(f32(bc[.NW].x) - f32(ac[.NE].x)) }
    else if b_is_bottom { return abs(f32(bc[.NE].y) - f32(ac[.SE].y)) }
    else if b_is_top    { return abs(f32(bc[.SE].y) - f32(ac[.NE].y)) }
    else { return 0 } // rects intersect
}

//https://stackoverflow.com/a/26178015
rects_distance :: proc{irects_distance, frects_distance, trects_distance}




irect_vector_dist :: proc(a: IRect, b: IVector) -> f32 {
    ac := get_rect_corners(a)

    axis_dist := FVector{
        max(f32(ac[.NW].x) - f32(b.x), f32(b.x) - f32(ac[.NE].x), 0),
        max(f32(ac[.NE].y) - f32(b.y), f32(b.y) - f32(ac[.SE].y), 0)
    }
    return vector_dist(axis_dist, FVECTOR_ZERO)
}
frect_vector_dist :: proc(a: FRect, b: FVector) -> f32 {
    ac := get_rect_corners(a)

    axis_dist := FVector{
        max(ac[.NW].x - b.x, b.x - ac[.NE].x, 0),
        max(ac[.NE].y - b.y, b.y - ac[.SE].y, 0)
    }
    return vector_dist(axis_dist, FVECTOR_ZERO)
}
trect_vector_dist :: proc(a: TRect, b: TVector) -> f32 {
    ac := get_rect_corners(a)

    axis_dist := FVector{
        max(f32(ac[.NW].x) - f32(b.x), f32(b.x) - f32(ac[.NE].x), 0),
        max(f32(ac[.NE].y) - f32(b.y), f32(b.y) - f32(ac[.SE].y), 0)
    }
    return vector_dist(axis_dist, FVECTOR_ZERO)
}

rect_vector_dist :: proc{irect_vector_dist, frect_vector_dist, trect_vector_dist}

get_frect_movement_defining_lines :: proc(rect: FRect, p_pos: FVector) -> (edge_line_a, mid_line, edge_line_b: FLine) {
    p_rect := rect
    p_rect.x = p_pos.x
    p_rect.y = p_pos.y

    corners := get_rect_corners(rect)
    p_corners := get_rect_corners(p_rect)

    direct_north_movement : bool = p_corners[.SW].y < corners[.SW].y && p_corners[.SW].x == corners[.SW].x && p_corners[.NE].x == corners[.NE].x
    direct_south_movement : bool = p_corners[.NW].y > corners[.NW].y && p_corners[.SW].x == corners[.SW].x && p_corners[.NE].x == corners[.NE].x

    direct_east_movement : bool = p_corners[.NW].x > corners[.NW].x && p_corners[.SW].y == corners[.SW].y && p_corners[.NE].y == corners[.NE].y
    direct_west_movement : bool = p_corners[.NE].x < corners[.NE].x && p_corners[.SW].y == corners[.SW].y && p_corners[.NE].y == corners[.NE].y

    if direct_north_movement {
        edge_line_a = FLine{corners[.SW], p_corners[.NW]}
        edge_line_b = FLine{corners[.SE], p_corners[.NE]}
        mid_line = FLine{corners[.SE], p_corners[.NE]}

        return
    }
    if direct_south_movement {
        edge_line_a = FLine{corners[.NW], p_corners[.SW]}
        edge_line_b = FLine{corners[.NE], p_corners[.SE]}
        mid_line = FLine{corners[.NE], p_corners[.SE]}

        return
    }
    if direct_east_movement {
        edge_line_a = FLine{corners[.NW], p_corners[.NE]}
        edge_line_b = FLine{corners[.SW], p_corners[.SE]}
        mid_line = FLine{corners[.SW], p_corners[.SE]}

        return
    }
    if direct_west_movement {
        edge_line_a = FLine{corners[.NE], p_corners[.NW]}
        edge_line_b = FLine{corners[.SE], p_corners[.SW]}
        mid_line = FLine{corners[.SE], p_corners[.SW]}

        return
    }

    NE_quadrant_movement : bool = p_corners[.SW].x > corners[.SW].x && p_corners[.SW].y < corners[.SW].y
    SW_quadrant_movement : bool = p_corners[.NE].x < corners[.NE].x && p_corners[.NE].y > corners[.NE].y
    SE_quadrant_movement : bool = p_corners[.SW].x > corners[.SW].x && p_corners[.NE].y > corners[.NE].y

    if NE_quadrant_movement {
        edge_line_a = FLine{corners[.NW], p_corners[.NW]}
        edge_line_b = FLine{corners[.SE], p_corners[.SE]}
        mid_line = FLine{corners[.SW], p_corners[.NE]}

        return
    }

    if SW_quadrant_movement {
        edge_line_a = FLine{corners[.NW], p_corners[.NW]}
        edge_line_b = FLine{corners[.SE], p_corners[.SE]}
        mid_line = FLine{corners[.NE], p_corners[.SW]}

        return
    }

    if SE_quadrant_movement {
        edge_line_a = FLine{corners[.NE], p_corners[.NE]}
        edge_line_b = FLine{corners[.SW], p_corners[.SW]}
        mid_line = FLine{corners[.NW], p_corners[.SE]}

        return
    }

    // NW quadrant
    edge_line_a = FLine{corners[.NE], p_corners[.NE]}
    edge_line_b = FLine{corners[.SW], p_corners[.SW]}
    mid_line = FLine{corners[.SE], p_corners[.NW]}

    return
}
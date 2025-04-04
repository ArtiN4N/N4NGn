package g4n
import sdl "vendor:sdl3"
import "core:fmt"
ILine :: struct {
    a, b: IVector
}

FLine :: struct {
    a, b: FVector
}

TLine :: struct {
    a, b: TVector
}

ILINE_ZERO :: ILine{{0,0},{0,0}}
FLINE_ZERO :: FLine{{0,0},{0,0}}
TLINE_ZERO :: TLine{{0,0},{0,0}}


iline_to_fline :: proc(l: ILine) -> (r: FLine) {
    r.a = to_fvector(l.a)
    r.b = to_fvector(l.b)
    return
}
tline_to_fline :: proc(l: TLine) -> (r: FLine) {
    r.a = to_fvector(l.a)
    r.b = to_fvector(l.b)
    return
}

to_fline :: proc{iline_to_fline, tline_to_fline}




iline_to_tline :: proc(l: ILine) -> (r: TLine) {
    if l.a.x < 0 || l.a.y < 0 || l.b.x < 0 || l.b.y < 0 {
        log("Uh oh! Casting negative int to unsigned int!")
    }
    r.a = to_tvector(l.a)
    r.b = to_tvector(l.b)
    return
}
fline_to_tline :: proc(l: FLine) -> (r: TLine) {
    if l.a.x < 0 || l.a.y < 0 || l.b.x < 0 || l.b.y < 0 {
        log("Uh oh! Casting negative int to unsigned int!")
    }
    r.a = to_tvector(l.a)
    r.b = to_tvector(l.b)
    return
}

to_tline :: proc{iline_to_tline, fline_to_tline}




fline_to_iline :: proc(l: FLine) -> (r: ILine) {
    r.a = to_ivector(l.a)
    r.b = to_ivector(l.b)
    return
}
tline_to_iline :: proc(l: TLine) -> (r: ILine) {
    r.a = to_ivector(l.a)
    r.b = to_ivector(l.b)
    return
}

to_iline :: proc{fline_to_iline, tline_to_iline}




cap_negative_iline_coords :: proc(i: ILine) -> (r: ILine) {
    r = i
    if r.a.x < 0 { r.a.x = 0 }
    if r.b.x < 0 { r.b.x = 0 }
    if r.a.y < 0 { r.a.y = 0 }
    if r.b.y < 0 { r.b.y = 0 }

    return
}
cap_negative_fline_coords :: proc(i: FLine) -> (r: FLine) {
    r = i
    if r.a.x < 0 { r.a.x = 0 }
    if r.b.x < 0 { r.b.x = 0 }
    if r.a.y < 0 { r.a.y = 0 }
    if r.b.y < 0 { r.b.y = 0 }

    return
}

cap_negative_line_coords :: proc{cap_negative_iline_coords, cap_negative_fline_coords}




iline_midpoint :: proc(i: ILine) -> IVector {
    return { (i.a.x + i.b.x) / 2, (i.a.y + i.b.y) / 2 }
}
fline_midpoint :: proc(i: FLine) -> FVector {
    return { (i.a.x + i.b.x) / 2, (i.a.y + i.b.y) / 2 }
}
tline_midpoint :: proc(i: TLine) -> TVector {
    return { (i.a.x + i.b.x) / 2, (i.a.y + i.b.y) / 2 }
}

get_line_midpoint :: proc{iline_midpoint, fline_midpoint, tline_midpoint}




get_iline_slope :: proc(l: ILine) -> (result: f32, ok: bool) {
    num := f32(l.b.y - l.a.y)
    denom := f32(l.b.x - l.a.x)

    if denom == 0 { return 0, false }

    return num / denom, true
}
get_fline_slope :: proc(l: FLine) -> (result: f32, ok: bool) {
    num := l.b.y - l.a.y
    denom := l.b.x - l.a.x

    if denom == 0 { return 0, false }

    return num / denom, true
}
get_tline_slope :: proc(l: TLine) -> (result: f32, ok: bool) {
    num := f32(l.b.y - l.a.y)
    denom := f32(l.b.x - l.a.x)

    if denom == 0 { return 0, false }

    return num / denom, true
}

get_line_slope :: proc{get_iline_slope, get_fline_slope, get_tline_slope}




ilines_collide :: proc(i, j: ILine) -> bool {
    q := i.a
    s := i.b - q
    p := j.a
    r := j.b - p

    denom := vector_cross(r, s)

    if denom == 0 { return i == j}

    t := vector_cross(q - p, s) / denom
    u := vector_cross(p - q, r) / denom

    return (0 <= t && t <= 1) && (0 <= u && u <= 1)
}

flines_collide :: proc(i, j: FLine) -> bool {
    q := i.a
    s := i.b - q
    p := j.a
    r := j.b - p

    denom := vector_cross(r, s)
    if denom == 0 { return i == j}

    t := vector_cross(q - p, s) / denom
    u := vector_cross(q - p, r) / denom

    return (0 <= t && t <= 1) && (0 <= u && u <= 1)

}

tlines_collide :: proc(i, j: TLine) -> bool {
    i := to_iline(i)
    j := to_iline(j)

    q := i.a
    s := i.b - q
    p := j.a
    r := j.b - p

    denom := vector_cross(s, r)
    if denom == 0 { return i == j}

    t := vector_cross(q - p, s) / denom
    u := vector_cross(p - q, r) / denom

    return (0 <= t && t <= 1) && (0 <= u && u <= 1)
}

lines_collide :: proc{ilines_collide, flines_collide, tlines_collide}




iline_intersects_rect :: proc(l: ILine, r: IRect) -> bool {
    // if line endpoint is contained within tile
    if rect_contains_vector(r, l.a) || rect_contains_vector(r, l.b) { return true }

    for rl in get_rect_lines(r) {
        if lines_collide(l, rl) { return true }
    }

    return false
}
fline_intersects_rect :: proc(l: FLine, r: FRect) -> bool {
    // if line endpoint is contained within tile
    if rect_contains_vector(r, l.a) || rect_contains_vector(r, l.b) { return true }
    for rl in get_rect_lines(r) {
        if lines_collide(l, rl) { return true }
    }

    return false
}
tline_intersects_rect :: proc(l: TLine, r: TRect) -> bool {
    // if line endpoint is contained within tile
    if rect_contains_vector(r, l.a) || rect_contains_vector(r, l.b) { return true }

    for rl in get_rect_lines(r) {
        if lines_collide(l, rl) { return true }
    }

    return false
}

line_intersects_rect :: proc{iline_intersects_rect, fline_intersects_rect, tline_intersects_rect}




iline_vector_distance :: proc(l: ILine, v: IVector) -> f32 {
    slope_1, slope_exists := get_line_slope(l)
    d1 : f32
    line_x : f32
    line_y : f32
    v_fpos := to_fvector(v)

    if slope_exists && slope_1 != 0 {
        slope_2 := -1 / slope_1
        line_x = ((slope_1 * f32(l.a.x) - f32(l.a.y)) - (slope_2 * f32(v.x) - f32(v.y))) / (slope_1 - slope_2)
        line_y = slope_1 * line_x - slope_1 * f32(l.a.x) + f32(l.a.y)
    } else if slope_exists && slope_1 == 0 {
        // horizontal line
        xmin := min(l.a.x, l.b.x)
        xmax := max(l.a.x, l.b.x)
        if xmin <= v.x && v.x <= xmax {
            return vector_dist(v_fpos, to_fvector(IVector{v.x, l.a.y}))
        }
    } else {
        // vertical line
        ymin := min(l.a.y, l.b.y)
        ymax := max(l.a.y, l.b.y)
        if ymin <= v.y && v.y <= ymax {
            return vector_dist(v_fpos, to_fvector(IVector{l.a.x, v.y}))
        }
    }
    
    d1 = vector_dist(v_fpos, FVector{line_x, line_y})
    contain_x := line_x < f32(max(l.a.x, l.b.x)) && line_x > f32(min(l.a.x, l.b.x))
    contain_y := line_y < f32(max(l.a.y, l.b.y)) && line_y > f32(min(l.a.y, l.b.y))

    if contain_x && contain_y { return d1 }

    d2 := vector_dist(v_fpos, to_fvector(l.a))
    d3 := vector_dist(v_fpos, to_fvector(l.b))

    return min(d2, d3)
}
fline_vector_distance :: proc(l: FLine, v: FVector) -> f32 {
    slope_1, slope_exists := get_line_slope(l)
    d1 : f32
    line_x : f32
    line_y : f32

    if slope_exists && slope_1 != 0 {
        slope_2 := -1 / slope_1
        line_x = ((slope_1 * f32(l.a.x) - f32(l.a.y)) - (slope_2 * f32(v.x) - f32(v.y))) / (slope_1 - slope_2)
        line_y = slope_1 * line_x - slope_1 * f32(l.a.x) + f32(l.a.y)
    } else if slope_exists && slope_1 == 0 {
        // horizontal line
        xmin := min(l.a.x, l.b.x)
        xmax := max(l.a.x, l.b.x)
        if xmin <= v.x && v.x <= xmax {
            return vector_dist(v, FVector{v.x, l.a.y})
        }
    } else {
        // vertical line
        ymin := min(l.a.y, l.b.y)
        ymax := max(l.a.y, l.b.y)
        if ymin <= v.y && v.y <= ymax {
            return vector_dist(v, FVector{l.a.x, v.y})
        }
    }
    
    d1 = vector_dist(v, FVector{line_x, line_y})
    contain_x := line_x < f32(max(l.a.x, l.b.x)) && line_x > f32(min(l.a.x, l.b.x))
    contain_y := line_y < f32(max(l.a.y, l.b.y)) && line_y > f32(min(l.a.y, l.b.y))

    if contain_x && contain_y { return d1 }

    d2 := vector_dist(v, l.a)
    d3 := vector_dist(v, l.b)

    return min(d2, d3)
}
tline_vector_distance :: proc(l: TLine, v: TVector) -> f32 {
    slope_1, slope_exists := get_line_slope(l)
    d1 : f32
    line_x : f32
    line_y : f32
    v_fpos := to_fvector(v)

    if slope_exists && slope_1 != 0 {
        slope_2 := -1 / slope_1
        line_x = ((slope_1 * f32(l.a.x) - f32(l.a.y)) - (slope_2 * f32(v.x) - f32(v.y))) / (slope_1 - slope_2)
        line_y = slope_1 * line_x - slope_1 * f32(l.a.x) + f32(l.a.y)
    } else if slope_exists && slope_1 == 0 {
        // horizontal line
        xmin := min(l.a.x, l.b.x)
        xmax := max(l.a.x, l.b.x)
        if xmin <= v.x && v.x <= xmax {
            return vector_dist(v_fpos, to_fvector(TVector{v.x, l.a.y}))
        }
    } else {
        // vertical line
        ymin := min(l.a.y, l.b.y)
        ymax := max(l.a.y, l.b.y)
        if ymin <= v.y && v.y <= ymax {
            return vector_dist(v_fpos, to_fvector(TVector{l.a.x, v.y}))
        }
    }
    
    d1 = vector_dist(v_fpos, FVector{line_x, line_y})
    contain_x := line_x < f32(max(l.a.x, l.b.x)) && line_x > f32(min(l.a.x, l.b.x))
    contain_y := line_y < f32(max(l.a.y, l.b.y)) && line_y > f32(min(l.a.y, l.b.y))

    if contain_x && contain_y { return d1 }

    d2 := vector_dist(v_fpos, to_fvector(l.a))
    d3 := vector_dist(v_fpos, to_fvector(l.b))

    return min(d2, d3)
}

line_vector_distance :: proc{iline_vector_distance, fline_vector_distance, tline_vector_distance}




iline_circle_distance :: proc(l: ILine, c: ICircle) -> f32 {
    return max(line_vector_distance(l, get_circle_position(c)) - f32(c.r), 0)
}
fline_circle_distance :: proc(l: FLine, c: FCircle) -> f32 {
    return max(line_vector_distance(l, get_circle_position(c)) - c.r, 0)
}
tline_circle_distance :: proc(l: TLine, c: TCircle) -> f32 {
    return max(line_vector_distance(l, get_circle_position(c)) - f32(c.r), 0)
}

line_circle_distance :: proc{iline_circle_distance, fline_circle_distance, tline_circle_distance}




iline_intersects_circle :: proc(l: ILine, c: ICircle) -> bool {
    return line_circle_distance(l, c) <= 0
}
fline_intersects_circle :: proc(l: FLine, c: FCircle) -> bool {
    return line_circle_distance(l, c) <= 0
}
tline_intersects_circle :: proc(l: TLine, c: TCircle) -> bool {
    return line_circle_distance(l, c) <= 0
}

line_intersects_circle :: proc{iline_intersects_circle, fline_intersects_circle, tline_intersects_circle}



ilines_distance :: proc(a: ILine, b: ILine) -> f32 {
    if lines_collide(a, b) { return 0 }

    return min(line_vector_distance(b, a.a), line_vector_distance(b, a.b), line_vector_distance(a, b.a), line_vector_distance(a, b.b))
}
flines_distance :: proc(a: FLine, b: FLine) -> f32 {
    if lines_collide(a, b) { return 0 }

    return min(line_vector_distance(b, a.a), line_vector_distance(b, a.b), line_vector_distance(a, b.a), line_vector_distance(a, b.b))
}
tlines_distance :: proc(a: TLine, b: TLine) -> f32 {
    if lines_collide(a, b) { return 0 }

    return min(line_vector_distance(b, a.a), line_vector_distance(b, a.b), line_vector_distance(a, b.a), line_vector_distance(a, b.b))
}

lines_distance :: proc{ilines_distance, flines_distance, tlines_distance}




iline_rectangle_distance :: proc(a: ILine, b: IRect) -> f32 {
    if rect_contains_vector(b, a.a) || rect_contains_vector(b, a.b) { return 0 }
    bl := get_rect_lines(b)
    return min(lines_distance(a, bl[.NO]), lines_distance(a, bl[.EA]), lines_distance(a, bl[.SO]), lines_distance(a, bl[.WE]))
}
fline_rectangle_distance :: proc(a: FLine, b: FRect) -> f32 {
    if rect_contains_vector(b, a.a) || rect_contains_vector(b, a.b) { return 0 }
    bl := get_rect_lines(b)
    return min(lines_distance(a, bl[.NO]), lines_distance(a, bl[.EA]), lines_distance(a, bl[.SO]), lines_distance(a, bl[.WE]))
}
tline_rectangle_distance :: proc(a: TLine, b: TRect) -> f32 {
    if rect_contains_vector(b, a.a) || rect_contains_vector(b, a.b) { return 0 }
    bl := get_rect_lines(b)
    return min(lines_distance(a, bl[.NO]), lines_distance(a, bl[.EA]), lines_distance(a, bl[.SO]), lines_distance(a, bl[.WE]))
}
line_rectangle_distance :: proc{iline_rectangle_distance, fline_rectangle_distance, tline_rectangle_distance}
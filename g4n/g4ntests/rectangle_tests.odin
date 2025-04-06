package g4ntests
import sdl "vendor:sdl3"
import g4n "../../g4n"
import "core:math"
import "core:testing"

@(test)
rect_from_nwse_test :: proc(t: ^testing.T) {
    a := g4n.IRect{0, 0, 3, 3}
    b := g4n.IRect{10, -4, 4, 2}
    c := g4n.FRect{-2.5, 8.88, 2, 7}
    d := g4n.TRect{10, 4, 3, 4}

    testing.expect_value(t, g4n.rect_from_nw_se(g4n.IVector{-1,-1},   g4n.IVector{1,1}), a)
    testing.expect_value(t, g4n.rect_from_nw_se(g4n.IVector{9,-4},    g4n.IVector{12,-3}), b)
    testing.expect_value(t, g4n.rect_from_nw_se(g4n.FVector{-3,5.88}, g4n.FVector{-2,11.88}), c)
    testing.expect_value(t, g4n.rect_from_nw_se(g4n.TVector{9,3},     g4n.TVector{11,6}), d)
}

@(test)
rect_pos_test :: proc(t: ^testing.T) {
    a := g4n.IRect{0, 0, 1, 1}
    b := g4n.FRect{-2.5, 8.88, 1, 1}
    c := g4n.TRect{2, 1, 1, 1}

    testing.expect_value(t, g4n.get_rect_position(a), g4n.IVector{0,0})
    testing.expect_value(t, g4n.get_rect_position(b), g4n.FVector{-2.5, 8.88})
    testing.expect_value(t, g4n.get_rect_position(c), g4n.TVector{2,1})
}

@(test)
rect_with_pos_test :: proc(t: ^testing.T) {
    a := g4n.IRect{0, 0, 1, 1}
    b := g4n.FRect{-2.5, 8.88, 1, 1}
    c := g4n.TRect{2, 1, 1, 1}

    d := g4n.IVector{0, 1}
    e := g4n.FVector{4.5, 7}
    f := g4n.TVector{10, 10}

    testing.expect_value(t, g4n.rect_with_position(a, d), g4n.IRect{0, 1, 1, 1})
    testing.expect_value(t, g4n.rect_with_position(b, e), g4n.FRect{4.5, 7, 1, 1})
    testing.expect_value(t, g4n.rect_with_position(c, f), g4n.TRect{10, 10, 1, 1})
}

@(test)
rect_size_test :: proc(t: ^testing.T) {
    a := g4n.IRect{0, 0, 1, 1}
    b := g4n.FRect{-2.5, 8.88, 4.4, 2}
    c := g4n.TRect{11, 5, 1, 99}

    testing.expect_value(t, g4n.get_rect_size(a), g4n.IVector{1,1})
    testing.expect_value(t, g4n.get_rect_size(b), g4n.FVector{4.4, 2})
    testing.expect_value(t, g4n.get_rect_size(c), g4n.TVector{1, 99})
}

@(test)
rect_add_vec_test :: proc(t: ^testing.T) {
    a     := g4n.IRect{0, 0, 1, 1}
    a_add := g4n.IVector{4, -10}
    b     := g4n.FRect{-2.5, 0.1, 1, 1}
    b_add := g4n.FVector{1.1, -0.2}
    c     := g4n.TRect{11, 5, 1, 1}
    c_add := g4n.TVector{1,1}

    testing.expect_value(t, g4n.get_rect_position(g4n.rect_add_vector(a, a_add)), g4n.IVector{4,-10})
    testing.expect_value(t, g4n.get_rect_position(g4n.rect_add_vector(b, b_add)), g4n.FVector{-1.4, -0.1})
    testing.expect_value(t, g4n.get_rect_position(g4n.rect_add_vector(c, c_add)), g4n.TVector{12,6})
}

@(test)
rect_corners_test :: proc(t: ^testing.T) {
    a := g4n.IRect{0, 0, 1, 1}
    b := g4n.FRect{-2.5, 8.88, 2, 2}
    c := g4n.TRect{11, 5, 10, 3}

    a_corners := g4n.IRectCorners{
        .NW = {0,0},
        .NE = {0,0},
        .SE = {0,0},
        .SW = {0,0},
    }
    
    b_corners := g4n.FRectCorners{
        .NW = {-3,8.38},
        .NE = {-2,8.38},
        .SE = {-2,9.38},
        .SW = {-3,9.38},
    }

    c_corners := g4n.TRectCorners{
        .NW = {7,4},
        .NE = {16,4},
        .SE = {16,6},
        .SW = {7,6},
    }

    testing.expect_value(t, g4n.get_rect_corners(a), a_corners)
    testing.expect_value(t, g4n.get_rect_corners(b), b_corners)
    testing.expect_value(t, g4n.get_rect_corners(c), c_corners)
}

@(test)
rect_lines_test :: proc(t: ^testing.T) {
    a := g4n.IRect{0, 0, 1, 1}
    b := g4n.FRect{-2.5, 8.88, 2, 2}
    c := g4n.TRect{11, 5, 10, 3}

    a_lines := g4n.IRectLines{
        .NO = {{0,0}, {0,0}},
        .EA = {{0,0}, {0,0}},
        .SO = {{0,0}, {0,0}},
        .WE = {{0,0}, {0,0}},
    }
    
    b_lines := g4n.FRectLines{
        .NO = {{-3,8.38}, {-2,8.38}},
        .EA = {{-2,8.38}, {-2,9.38}},
        .SO = {{-2,9.38}, {-3,9.38}},
        .WE = {{-3,9.38}, {-3,8.38}},
    }

    c_lines := g4n.TRectLines{
        .NO = {{7,4}, {16,4}},
        .EA = {{16,4}, {16,6}},
        .SO = {{16,6}, {7,6}},
        .WE = {{7,6}, {7,4}},
    }

    testing.expect_value(t, g4n.get_rect_lines(a), a_lines)
    testing.expect_value(t, g4n.get_rect_lines(b), b_lines)
    testing.expect_value(t, g4n.get_rect_lines(c), c_lines)
}

@(test)
rect_contains_vec_test :: proc(t: ^testing.T) {
    a := g4n.IRect{0, 0, 1, 1}
    b := g4n.FRect{-2.5, 8.88, 2, 2}
    c := g4n.TRect{11, 5, 10, 3}

    d := g4n.IVector{0, 0}
    e := g4n.IVector{1, 1}

    f := g4n.FVector{-2.1, 8.38}
    g := g4n.FVector{-2.5, 8.88}
    h := g4n.FVector{-2.9, 9.40}

    i := g4n.TVector{11, 6}
    j := g4n.TVector{16, 5}
    k := g4n.TVector{17, 7}

    testing.expect(t, g4n.rect_contains_vector(a,d))
    testing.expect(t, !g4n.rect_contains_vector(a,e))
    testing.expect(t, g4n.rect_contains_vector(b,f))
    testing.expect(t, g4n.rect_contains_vector(b,g))
    testing.expect(t, !g4n.rect_contains_vector(b,h))
    testing.expect(t, g4n.rect_contains_vector(c,i))
    testing.expect(t, g4n.rect_contains_vector(c,j))
    testing.expect(t, !g4n.rect_contains_vector(c,k))
}

@(test)
rect_collides_test :: proc(t: ^testing.T) {
    a := g4n.IRect{0, 0, 1, 1}
    b := g4n.IRect{-5, -5, 10, 10}
    c := g4n.IRect{-6, -6, 2, 2}
    d := g4n.IRect{4, 5, 1, 1}

    e := g4n.FRect{-2.5, 8.88, 2, 2}
    f := g4n.FRect{-2, 6.14, 1, 6}
    g := g4n.FRect{3, 6.14, 3, 4}

    h := g4n.TRect{16, 4, 1, 3}
    i := g4n.TRect{11, 3, 10, 3}
    j := g4n.TRect{11, 0, 1, 3}

    testing.expect(t, g4n.rects_collide(a,b))
    testing.expect(t, g4n.rects_collide(b,c))
    testing.expect(t, !g4n.rects_collide(c,d))
    testing.expect(t, g4n.rects_collide(e,f))
    testing.expect(t, !g4n.rects_collide(f,g))
    testing.expect(t, g4n.rects_collide(h,i))
    testing.expect(t, !g4n.rects_collide(i,j))
}

@(test)
rects_distance_test :: proc(t: ^testing.T) {
    a := g4n.IRect{1, 1, 3, 3}
    b := g4n.IRect{1, 1, 1, 1}
    c := g4n.IRect{3, 3, 4, 3}
    d := g4n.IRect{-1, -1, 1, 1}
    e := g4n.IRect{1, -3, 1, 1}
    f := g4n.IRect{5, -3, 1, 1}
    g := g4n.IRect{5, -3, 10, 1}

    h := g4n.FRect{4.32, -7.1, 1.6, 10.4}
    i := g4n.FRect{99.45, 23, 8.1, 63.32}

    j := g4n.TRect{1, 1, 3, 3}
    k := g4n.TRect{5, 4, 3, 2}

    testing.expect_value(t, g4n.rects_distance(a,b), 0)
    testing.expect_value(t, g4n.rects_distance(a,c), 0)
    testing.expect_value(t, g4n.rects_distance(a,d), math.sqrt_f32(2))
    testing.expect_value(t, g4n.rects_distance(a,e), 3)
    testing.expect_value(t, g4n.rects_distance(a,f), math.sqrt_f32(18))
    testing.expect_value(t, g4n.rects_distance(a,g), 3)

    testing.expect(t, abs(g4n.rects_distance(h,i) - 91.28) < 0.0001)

    testing.expect_value(t, g4n.rects_distance(j,k), math.sqrt_f32(8))
}

@(test)
rect_vector_distance_test :: proc(t: ^testing.T) {
    a := g4n.IRect{5, -3, 10, 2}
    b := g4n.FRect{99.45, 23, 8.1, 63.32}
    c := g4n.TRect{5, 4, 3, 2}

    testing.expect_value(t, g4n.rect_vector_dist(a,g4n.IVector{4,-3}), 0)
    testing.expect_value(t, g4n.rect_vector_dist(a,g4n.IVector{4,0}), 2)
    testing.expect_value(t, g4n.rect_vector_dist(a,g4n.IVector{-1,0}), math.sqrt_f32(8))
    testing.expect_value(t, g4n.rect_vector_dist(a,g4n.IVector{10,-6}), 3)

    testing.expect(t, abs(g4n.rect_vector_dist(b,g4n.FVector{0,-20}) - math.sqrt_f32(9336.9956)) < 0.0001)

    testing.expect_value(t, g4n.rect_vector_dist(c,g4n.TVector{4,4}), 0)
}

@(test)
test_rect_movement_defining_lines :: proc(t: ^testing.T) {
    rect := g4n.FRect{ 10, 10, 10, 12}

    pos_1 := g4n.FVector{10, 0}
    pos_2 := g4n.FVector{15, 5}
    pos_3 := g4n.FVector{20, 10}
    pos_4 := g4n.FVector{15, 15}
    pos_5 := g4n.FVector{10, 20}
    pos_6 := g4n.FVector{5, 15}
    pos_7 := g4n.FVector{0, 10}
    pos_8 := g4n.FVector{5, 5}

    corners_r := g4n.get_rect_corners(rect)

    corners_1 := g4n.get_rect_corners(g4n.rect_with_position(rect, pos_1))
    corners_2 := g4n.get_rect_corners(g4n.rect_with_position(rect, pos_2))
    corners_3 := g4n.get_rect_corners(g4n.rect_with_position(rect, pos_3))
    corners_4 := g4n.get_rect_corners(g4n.rect_with_position(rect, pos_4))
    corners_5 := g4n.get_rect_corners(g4n.rect_with_position(rect, pos_5))
    corners_6 := g4n.get_rect_corners(g4n.rect_with_position(rect, pos_6))
    corners_7 := g4n.get_rect_corners(g4n.rect_with_position(rect, pos_7))
    corners_8 := g4n.get_rect_corners(g4n.rect_with_position(rect, pos_8))

    ela_1, ml_1, elb_1 := g4n.get_frect_movement_defining_lines(rect, pos_1)
    ela_2, ml_2, elb_2 := g4n.get_frect_movement_defining_lines(rect, pos_2)
    ela_3, ml_3, elb_3 := g4n.get_frect_movement_defining_lines(rect, pos_3)
    ela_4, ml_4, elb_4 := g4n.get_frect_movement_defining_lines(rect, pos_4)
    ela_5, ml_5, elb_5 := g4n.get_frect_movement_defining_lines(rect, pos_5)
    ela_6, ml_6, elb_6 := g4n.get_frect_movement_defining_lines(rect, pos_6)
    ela_7, ml_7, elb_7 := g4n.get_frect_movement_defining_lines(rect, pos_7)
    ela_8, ml_8, elb_8 := g4n.get_frect_movement_defining_lines(rect, pos_8)

    testing.expect_value(t, ela_1, g4n.FLine{corners_r[.SW], corners_1[.NW]})
    testing.expect_value(t,  ml_1, g4n.FLine{corners_r[.SE], corners_1[.NE]})
    testing.expect_value(t, elb_1, g4n.FLine{corners_r[.SE], corners_1[.NE]})

    testing.expect_value(t, ela_2, g4n.FLine{corners_r[.NW], corners_2[.NW]})
    testing.expect_value(t,  ml_2, g4n.FLine{corners_r[.SW], corners_2[.NE]})
    testing.expect_value(t, elb_2, g4n.FLine{corners_r[.SE], corners_2[.SE]})

    testing.expect_value(t, ela_3, g4n.FLine{corners_r[.NW], corners_3[.NE]})
    testing.expect_value(t,  ml_3, g4n.FLine{corners_r[.SW], corners_3[.SE]})
    testing.expect_value(t, elb_3, g4n.FLine{corners_r[.SW], corners_3[.SE]})

    testing.expect_value(t, ela_4, g4n.FLine{corners_r[.NE], corners_4[.NE]})
    testing.expect_value(t,  ml_4, g4n.FLine{corners_r[.NW], corners_4[.SE]})
    testing.expect_value(t, elb_4, g4n.FLine{corners_r[.SW], corners_4[.SW]})

    testing.expect_value(t, ela_5, g4n.FLine{corners_r[.NW], corners_5[.SW]})
    testing.expect_value(t,  ml_5, g4n.FLine{corners_r[.NE], corners_5[.SE]})
    testing.expect_value(t, elb_5, g4n.FLine{corners_r[.NE], corners_5[.SE]})

    testing.expect_value(t, ela_6, g4n.FLine{corners_r[.NW], corners_6[.NW]})
    testing.expect_value(t,  ml_6, g4n.FLine{corners_r[.NE], corners_6[.SW]})
    testing.expect_value(t, elb_6, g4n.FLine{corners_r[.SE], corners_6[.SE]})

    testing.expect_value(t, ela_7, g4n.FLine{corners_r[.NE], corners_7[.NW]})
    testing.expect_value(t,  ml_7, g4n.FLine{corners_r[.SE], corners_7[.SW]})
    testing.expect_value(t, elb_7, g4n.FLine{corners_r[.SE], corners_7[.SW]})

    testing.expect_value(t, ela_8, g4n.FLine{corners_r[.NE], corners_8[.NE]})
    testing.expect_value(t,  ml_8, g4n.FLine{corners_r[.SE], corners_8[.NW]})
    testing.expect_value(t, elb_8, g4n.FLine{corners_r[.SW], corners_8[.SW]})
}
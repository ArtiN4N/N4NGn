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
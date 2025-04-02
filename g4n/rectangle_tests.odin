package g4n
import sdl "vendor:sdl3"
import "core:testing"
import "core:math"

@(test)
rect_from_nwse_test :: proc(t: ^testing.T) {
    a := IRect{0, 0, 3, 3}
    b := IRect{10, -4, 4, 2}
    c := FRect{-2.5, 8.88, 2, 7}
    d := TRect{10, 4, 3, 4}

    testing.expect_value(t, rect_from_nw_se(IVector{-1,-1}, IVector{1,1}), a)
    testing.expect_value(t, rect_from_nw_se(IVector{9,-4}, IVector{12,-3}), b)
    testing.expect_value(t, rect_from_nw_se(FVector{-3,5.88}, FVector{-2,11.88}), c)
    testing.expect_value(t, rect_from_nw_se(TVector{9,3}, TVector{11,6}), d)
}

@(test)
rect_pos_test :: proc(t: ^testing.T) {
    a := IRect{0, 0, 1, 1}
    b := FRect{-2.5, 8.88, 1, 1}
    c := TRect{2, 1, 1, 1}

    testing.expect_value(t, get_rect_position(a), IVector{0,0})
    testing.expect_value(t, get_rect_position(b), FVector{-2.5, 8.88})
    testing.expect_value(t, get_rect_position(c), TVector{2,1})
}

@(test)
rect_size_test :: proc(t: ^testing.T) {
    a := IRect{0, 0, 1, 1}
    b := FRect{-2.5, 8.88, 4.4, 2}
    c := TRect{11, 5, 1, 99}

    testing.expect_value(t, get_rect_size(a), IVector{1,1})
    testing.expect_value(t, get_rect_size(b), FVector{4.4, 2})
    testing.expect_value(t, get_rect_size(c), TVector{1, 99})
}

@(test)
rect_add_vec_test :: proc(t: ^testing.T) {
    a := IRect{0, 0, 1, 1}
    a_add := IVector{4, -10}
    b := FRect{-2.5, 0.1, 1, 1}
    b_add := FVector{1.1, -0.2}
    c := TRect{11, 5, 1, 1}
    c_add := TVector{1,1}

    testing.expect_value(t, get_rect_position(rect_add_vector(a, a_add)), IVector{4,-10})
    testing.expect_value(t, get_rect_position(rect_add_vector(b, b_add)), FVector{-1.4, -0.1})
    testing.expect_value(t, get_rect_position(rect_add_vector(c, c_add)), TVector{12,6})
}

@(test)
rect_corners_test :: proc(t: ^testing.T) {
    a := IRect{0, 0, 1, 1}
    b := FRect{-2.5, 8.88, 2, 2}
    c := TRect{11, 5, 10, 3}

    a_corners := IRectCorners{
        .NW = {0,0},
        .NE = {0,0},
        .SE = {0,0},
        .SW = {0,0},
    }
    
    b_corners := FRectCorners{
        .NW = {-3,8.38},
        .NE = {-2,8.38},
        .SE = {-2,9.38},
        .SW = {-3,9.38},
    }

    c_corners := TRectCorners{
        .NW = {7,4},
        .NE = {16,4},
        .SE = {16,6},
        .SW = {7,6},
    }

    testing.expect_value(t, get_rect_corners(a), a_corners)
    testing.expect_value(t, get_rect_corners(b), b_corners)
    testing.expect_value(t, get_rect_corners(c), c_corners)
}

@(test)
rect_lines_test :: proc(t: ^testing.T) {
    a := IRect{0, 0, 1, 1}
    b := FRect{-2.5, 8.88, 2, 2}
    c := TRect{11, 5, 10, 3}

    a_lines := IRectLines{
        .NO = {{0,0}, {0,0}},
        .EA = {{0,0}, {0,0}},
        .SO = {{0,0}, {0,0}},
        .WE = {{0,0}, {0,0}},
    }
    
    b_lines := FRectLines{
        .NO = {{-3,8.38}, {-2,8.38}},
        .EA = {{-2,8.38}, {-2,9.38}},
        .SO = {{-2,9.38}, {-3,9.38}},
        .WE = {{-3,9.38}, {-3,8.38}},
    }

    c_lines := TRectLines{
        .NO = {{7,4}, {16,4}},
        .EA = {{16,4}, {16,6}},
        .SO = {{16,6}, {7,6}},
        .WE = {{7,6}, {7,4}},
    }

    testing.expect_value(t, get_rect_lines(a), a_lines)
    testing.expect_value(t, get_rect_lines(b), b_lines)
    testing.expect_value(t, get_rect_lines(c), c_lines)
}

@(test)
rect_contains_vec_test :: proc(t: ^testing.T) {
    a := IRect{0, 0, 1, 1}
    b := FRect{-2.5, 8.88, 2, 2}
    c := TRect{11, 5, 10, 3}

    d := IVector{0, 0}
    e := IVector{1, 1}

    f := FVector{-2.1, 8.38}
    g := FVector{-2.5, 8.88}
    h := FVector{-2.9, 9.40}

    i := TVector{11, 6}
    j := TVector{16, 5}
    k := TVector{17, 7}

    testing.expect(t, rect_contains_vector(a,d))
    testing.expect(t, !rect_contains_vector(a,e))
    testing.expect(t, rect_contains_vector(b,f))
    testing.expect(t, rect_contains_vector(b,g))
    testing.expect(t, !rect_contains_vector(b,h))
    testing.expect(t, rect_contains_vector(c,i))
    testing.expect(t, rect_contains_vector(c,j))
    testing.expect(t, !rect_contains_vector(c,k))
}

@(test)
rect_collides_test :: proc(t: ^testing.T) {
    a := IRect{0, 0, 1, 1}
    b := IRect{-5, -5, 10, 10}
    c := IRect{-6, -6, 2, 2}
    d := IRect{4, 5, 1, 1}

    e := FRect{-2.5, 8.88, 2, 2}
    f := FRect{-2, 6.14, 1, 6}
    g := FRect{3, 6.14, 3, 4}

    h := TRect{16, 4, 1, 3}
    i := TRect{11, 3, 10, 3}
    j := TRect{11, 0, 1, 3}

    testing.expect(t, rects_collide(a,b))
    testing.expect(t, rects_collide(b,c))
    testing.expect(t, !rects_collide(c,d))
    testing.expect(t, rects_collide(e,f))
    testing.expect(t, !rects_collide(f,g))
    testing.expect(t, rects_collide(h,i))
    testing.expect(t, !rects_collide(i,j))
}

@(test)
rects_distance_test :: proc(t: ^testing.T) {
    a := IRect{1, 1, 3, 3}
    b := IRect{1, 1, 1, 1}
    c := IRect{3, 3, 4, 3}
    d := IRect{-1, -1, 1, 1}
    e := IRect{1, -3, 1, 1}
    f := IRect{5, -3, 1, 1}
    g := IRect{5, -3, 10, 1}

    h := FRect{4.32, -7.1, 1.6, 10.4}
    i := FRect{99.45, 23, 8.1, 63.32}

    j := TRect{1, 1, 3, 3}
    k := TRect{5, 4, 3, 2}

    testing.expect_value(t, rects_distance(a,b), 0)
    testing.expect_value(t, rects_distance(a,c), 0)
    testing.expect_value(t, rects_distance(a,d), math.sqrt_f32(2))
    testing.expect_value(t, rects_distance(a,e), 3)
    testing.expect_value(t, rects_distance(a,f), math.sqrt_f32(18))
    testing.expect_value(t, rects_distance(a,g), 3)

    testing.expect(t, abs(rects_distance(h,i) - 91.28) < 0.0001)

    testing.expect_value(t, rects_distance(j,k), math.sqrt_f32(8))
}

@(test)
rect_vector_distance_test :: proc(t: ^testing.T) {
    a := IRect{5, -3, 10, 2}
    b := FRect{99.45, 23, 8.1, 63.32}
    c := TRect{5, 4, 3, 2}

    testing.expect_value(t, rect_vector_dist(a,IVector{4,-3}), 0)
    testing.expect_value(t, rect_vector_dist(a,IVector{4,0}), 2)
    testing.expect_value(t, rect_vector_dist(a,IVector{-1,0}), math.sqrt_f32(8))
    testing.expect_value(t, rect_vector_dist(a,IVector{10,-6}), 3)

    testing.expect(t, abs(rect_vector_dist(b,FVector{0,-20}) - math.sqrt_f32(9336.9956)) < 0.0001)

    testing.expect_value(t, rect_vector_dist(c,TVector{4,4}), 0)
}
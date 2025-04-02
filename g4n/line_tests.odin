package g4n
import sdl "vendor:sdl3"
import "core:testing"
import "core:math"

@(test)
line_mid_test :: proc(t: ^testing.T) {
    a := ILine{{5,5}, IVECTOR_ZERO}
    b := FLine{{-1.7,5.6}, {4.0, 5.5}}
    c := TLine{{10, 10}, {2,3}}

    testing.expect_value(t, get_line_midpoint(a), IVector{2,2})
    testing.expect_value(t, get_line_midpoint(b), FVector{1.15,5.55})
    testing.expect_value(t, get_line_midpoint(c), TVector{6,6})
}

@(test)
line_collision_test :: proc(t: ^testing.T) {
    a := ILine{{5,5}, IVECTOR_ZERO}
    b := ILine{{-2,1}, {7,1}}
    c := FLine{{-1.7,5.5}, {4.0, 5.6}}
    d := FLine{{-1.7,5.5}, {-4.0, -5.6}}
    e := TLine{{10, 10}, {2,2}}
    f := TLine{{10, 12}, {2,3}}
    g := TLine{{10, 11}, {2,3}}

    testing.expect(t, lines_collide(a,b))
    testing.expect(t, lines_collide(a,a))
    testing.expect(t, lines_collide(c,d))
    testing.expect(t, !lines_collide(e,f))
    testing.expect(t, !lines_collide(e,g))
}

@(test)
line_rect_intersect_test :: proc(t: ^testing.T) {
    a := ILine{{5,5}, IVECTOR_ZERO}
    b := FLine{{-1.7,5.6}, {4.0, 5.5}}
    c := TLine{{10, 10}, {20,10}}

    d := IRect{4, 4, 10, 10}
    e := IRect{-1, -1, 2, 2}
    f := FRect{0, 4, 3, 5}
    g := FRect{0, 4, 2, 2}
    h := TRect{20, 10, 1, 1}
    i := TRect{9, 10, 1, 1}

    testing.expect(t, line_intersects_rect(a,d))
    testing.expect(t, line_intersects_rect(a,e))
    testing.expect(t, line_intersects_rect(b,f))
    testing.expect(t, !line_intersects_rect(b,g))
    testing.expect(t, line_intersects_rect(c,h))
    testing.expect(t, !line_intersects_rect(c,i))
}

@(test)
line_vector_dist_test :: proc(t: ^testing.T) {
    a := ILine{{5,5}, IVECTOR_ZERO}
    b := FLine{{-1.7,5.6}, {4.0, 5.5}}
    c := TLine{{10, 10}, {20,10}}

    testing.expect_value(t, line_vector_distance(a, get_line_midpoint(a)), 0)
    testing.expect_value(t, line_vector_distance(a, a.a), 0)
    testing.expect_value(t, line_vector_distance(a, a.b), 0)
    testing.expect_value(t, line_vector_distance(a, IVector{5,7}), 2)
    testing.expect_value(t, line_vector_distance(a, IVector{6,0}), math.sqrt_f32(18))
    testing.expect_value(t, line_vector_distance(a, IVector{6,4}), math.sqrt_f32(2))
    testing.expect_value(t, line_vector_distance(a, IVector{8,4}), math.sqrt_f32(10))

    testing.expect(t, abs(line_vector_distance(b, FVector{1.15,5.85})- math.sqrt_f32(0.089973696744)) < 0.0001)

    testing.expect_value(t, line_vector_distance(c, TVector{6,6}), math.sqrt_f32(32))
}

@(test)
line_circle_dist_test :: proc(t: ^testing.T) {
    a := ILine{{5,5}, IVECTOR_ZERO}
    b := FLine{{-1.7,5.6}, {4.0, 5.5}}
    c := TLine{{10, 10}, {20,10}}

    d := ICircle{2, 2, 1}
    e := ICircle{5, 5, 1}
    f := ICircle{0, 0, 1}
    g := ICircle{5, 7, 1}
    h := ICircle{6, 0, 4}
    i := ICircle{6, 4, 1}
    j := ICircle{8, 4, 3}

    k := FCircle{1.15, 5.85, 0.003}

    l := TCircle{6, 6, 5}

    testing.expect_value(t, line_circle_distance(a, d), 0)
    testing.expect_value(t, line_circle_distance(a, e), 0)
    testing.expect_value(t, line_circle_distance(a, f), 0)
    testing.expect_value(t, line_circle_distance(a, g), 1)
    testing.expect_value(t, line_circle_distance(a, h), math.sqrt_f32(18) - 4)
    testing.expect_value(t, line_circle_distance(a, i), math.sqrt_f32(2) - 1)
    testing.expect_value(t, line_circle_distance(a, j), math.sqrt_f32(10) - 3)

    testing.expect(t, abs(line_circle_distance(b, k) - math.sqrt_f32(0.089973696744) + 0.003) < 0.0001)

    testing.expect_value(t, line_circle_distance(c, l), math.sqrt_f32(32) - 5)
}

@(test)
line_circle_collide_test :: proc(t: ^testing.T) {
    a := ILine{{5,5}, IVECTOR_ZERO}
    b := FLine{{-1.7,5.6}, {4.0, 5.5}}
    c := TLine{{10, 10}, {20,10}}

    d := ICircle{2, 2, 1}
    e := ICircle{5, 5, 1}
    f := ICircle{0, 0, 1}
    g := ICircle{5, 7, 1}
    h := ICircle{6, 0, 4}
    i := ICircle{6, 4, 2}
    j := ICircle{8, 4, 4}

    k := FCircle{1.15, 5.85, 6.87}

    l := TCircle{6, 6, 5}

    testing.expect(t, line_intersects_circle(a, d))
    testing.expect(t, line_intersects_circle(a, e))
    testing.expect(t, line_intersects_circle(a, f))
    testing.expect(t, !line_intersects_circle(a, g))
    testing.expect(t, !line_intersects_circle(a, h))
    testing.expect(t, line_intersects_circle(a, i))
    testing.expect(t, line_intersects_circle(a, j))

    testing.expect(t, line_intersects_circle(b, k))

    testing.expect(t, !line_intersects_circle(c, l))
}
@(test)
lines_dist_test :: proc(t: ^testing.T) {
    a := ILine{{5,5}, {4,4}}
    b := ILine{{-2,0}, {7,1}}
    c := FLine{{-1.7,5.5}, {4.0, 5.6}}
    d := FLine{{-17.8,5.8}, {-4.0, -5.6}}
    e := TLine{{10, 10}, {2,2}}
    f := TLine{{10, 12}, {2,3}}
    g := TLine{{10, 11}, {2,3}}

    testing.expect_value(t, lines_distance(a,a), 0)
    testing.expect(t, abs(lines_distance(a,b) - math.sqrt_f32(10.9755878049)) < 0.0001)
    testing.expect(t, abs(lines_distance(c,d) - math.sqrt_f32(100.45056)) < 0.0001)
    testing.expect_value(t, lines_distance(e,f), math.sqrt_f32(0.5))
    testing.expect_value(t, lines_distance(f,g), 0)
}

@(test)
line_rect_dist_test :: proc(t: ^testing.T) {
    a := rect_from_nw_se(IVector{1, -4}, IVector{5, 10})
    b := rect_from_nw_se(FVector{-3,5.88}, FVector{-2,11.88})
    c := rect_from_nw_se(TVector{9,3}, TVector{11,6})

    d := ILine{{3, 12}, {3, -6}}
    e := ILine{{3, 9}, {3, 8}}
    f := ILine{{1, 10}, {5, 10}}
    g := ILine{{3, 15}, {3, 12}}
    
    h := FLine{{-5, 0}, {4, 10}}

    i := TLine{{0, 0}, {4, 10}}

    testing.expect_value(t, line_rectangle_distance(d, a), 0)
    testing.expect_value(t, line_rectangle_distance(e, a), 0)
    testing.expect_value(t, line_rectangle_distance(f, a), 0)
    testing.expect_value(t, line_rectangle_distance(g, a), 2)

    testing.expect(t, abs(line_rectangle_distance(h, b) - math.sqrt_f32(2.9022671609)) < 0.0001)

    testing.expect(t, abs(line_rectangle_distance(i, c) - math.sqrt_f32(37.5517696552)) < 0.0001)
}
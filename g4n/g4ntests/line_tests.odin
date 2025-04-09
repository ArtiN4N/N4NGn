package g4ntests
import sdl "vendor:sdl3"
import g4n "../../g4n"
import "core:math"
import "core:testing"

@(test)
line_mid_test :: proc(t: ^testing.T) {
    a := g4n.ILine{{5,5}, g4n.IVECTOR_ZERO}
    b := g4n.FLine{{-1.7,5.6}, {4.0, 5.5}}
    c := g4n.TLine{{10, 10}, {2,3}}

    testing.expect_value(t, g4n.get_line_midpoint(a), g4n.IVector{2,2})
    testing.expect_value(t, g4n.get_line_midpoint(b), g4n.FVector{1.15,5.55})
    testing.expect_value(t, g4n.get_line_midpoint(c), g4n.TVector{6,6})
}

@(test)
line_collision_test :: proc(t: ^testing.T) {
    a := g4n.ILine{{5,5}, g4n.IVECTOR_ZERO}
    b := g4n.ILine{{-2,1}, {7,1}}
    c := g4n.FLine{{-1.7,5.5}, {4.0, 5.6}}
    d := g4n.FLine{{-1.7,5.5}, {-4.0, -5.6}}
    e := g4n.TLine{{10, 10}, {2,2}}
    f := g4n.TLine{{10, 12}, {2,3}}
    g := g4n.TLine{{10, 11}, {2,3}}

    testing.expect(t, g4n.lines_collide(a,b))
    testing.expect(t, g4n.lines_collide(a,a))
    testing.expect(t, g4n.lines_collide(c,d))
    testing.expect(t, !g4n.lines_collide(e,f))
    testing.expect(t, !g4n.lines_collide(e,g))
}

@(test)
line_rect_intersect_test :: proc(t: ^testing.T) {
    a := g4n.ILine{{5,5}, g4n.IVECTOR_ZERO}
    b := g4n.FLine{{-1.7,5.6}, {4.0, 5.5}}
    c := g4n.TLine{{10, 10}, {20,10}}

    d := g4n.IRect{4, 4, 10, 10}
    e := g4n.IRect{-1, -1, 2, 2}
    f := g4n.FRect{0, 4, 3, 5}
    g := g4n.FRect{0, 4, 2, 2}
    h := g4n.TRect{20, 10, 1, 1}
    i := g4n.TRect{9, 10, 1, 1}

    testing.expect(t, g4n.line_intersects_rect(a,d))
    testing.expect(t, g4n.line_intersects_rect(a,e))
    testing.expect(t, g4n.line_intersects_rect(b,f))
    testing.expect(t, !g4n.line_intersects_rect(b,g))
    testing.expect(t, g4n.line_intersects_rect(c,h))
    testing.expect(t, !g4n.line_intersects_rect(c,i))
}

@(test)
line_vector_dist_test :: proc(t: ^testing.T) {
    a := g4n.ILine{{5,5}, g4n.IVECTOR_ZERO}
    b := g4n.FLine{{-1.7,5.6}, {4.0, 5.5}}
    c := g4n.TLine{{10, 10}, {20,10}}

    testing.expect_value(t, g4n.line_vector_distance(a, g4n.get_line_midpoint(a)), 0)
    testing.expect_value(t, g4n.line_vector_distance(a, a.a), 0)
    testing.expect_value(t, g4n.line_vector_distance(a, a.b), 0)
    testing.expect_value(t, g4n.line_vector_distance(a, g4n.IVector{5,7}), 2)
    testing.expect_value(t, g4n.line_vector_distance(a, g4n.IVector{6,0}), math.sqrt_f32(18))
    testing.expect_value(t, g4n.line_vector_distance(a, g4n.IVector{6,4}), math.sqrt_f32(2))
    testing.expect_value(t, g4n.line_vector_distance(a, g4n.IVector{8,4}), math.sqrt_f32(10))

    testing.expect(t, abs(g4n.line_vector_distance(b, g4n.FVector{1.15,5.85})- math.sqrt_f32(0.089973696744)) < 0.0001)

    testing.expect_value(t, g4n.line_vector_distance(c, g4n.TVector{6,6}), math.sqrt_f32(32))
}

@(test)
line_circle_dist_test :: proc(t: ^testing.T) {
    a := g4n.ILine{{5,5}, g4n.IVECTOR_ZERO}
    b := g4n.FLine{{-1.7,5.6}, {4.0, 5.5}}
    c := g4n.TLine{{10, 10}, {20,10}}

    d := g4n.ICircle{2, 2, 1}
    e := g4n.ICircle{5, 5, 1}
    f := g4n.ICircle{0, 0, 1}
    g := g4n.ICircle{5, 7, 1}
    h := g4n.ICircle{6, 0, 4}
    i := g4n.ICircle{6, 4, 1}
    j := g4n.ICircle{8, 4, 3}

    k := g4n.FCircle{1.15, 5.85, 0.003}

    l := g4n.TCircle{6, 6, 5}

    testing.expect_value(t, g4n.line_circle_distance(a, d), 0)
    testing.expect_value(t, g4n.line_circle_distance(a, e), 0)
    testing.expect_value(t, g4n.line_circle_distance(a, f), 0)
    testing.expect_value(t, g4n.line_circle_distance(a, g), 1)
    testing.expect_value(t, g4n.line_circle_distance(a, h), math.sqrt_f32(18) - 4)
    testing.expect_value(t, g4n.line_circle_distance(a, i), math.sqrt_f32(2) - 1)
    testing.expect_value(t, g4n.line_circle_distance(a, j), math.sqrt_f32(10) - 3)

    testing.expect(t, abs(g4n.line_circle_distance(b, k) - math.sqrt_f32(0.089973696744) + 0.003) < 0.0001)

    testing.expect_value(t, g4n.line_circle_distance(c, l), math.sqrt_f32(32) - 5)
}

@(test)
line_circle_collide_test :: proc(t: ^testing.T) {
    a := g4n.ILine{{5,5}, g4n.IVECTOR_ZERO}
    b := g4n.FLine{{-1.7,5.6}, {4.0, 5.5}}
    c := g4n.TLine{{10, 10}, {20,10}}

    d := g4n.ICircle{2, 2, 1}
    e := g4n.ICircle{5, 5, 1}
    f := g4n.ICircle{0, 0, 1}
    g := g4n.ICircle{5, 7, 1}
    h := g4n.ICircle{6, 0, 4}
    i := g4n.ICircle{6, 4, 2}
    j := g4n.ICircle{8, 4, 4}

    k := g4n.FCircle{1.15, 5.85, 6.87}

    l := g4n.TCircle{6, 6, 5}

    testing.expect(t, g4n.line_intersects_circle(a, d))
    testing.expect(t, g4n.line_intersects_circle(a, e))
    testing.expect(t, g4n.line_intersects_circle(a, f))
    testing.expect(t, !g4n.line_intersects_circle(a, g))
    testing.expect(t, !g4n.line_intersects_circle(a, h))
    testing.expect(t, g4n.line_intersects_circle(a, i))
    testing.expect(t, g4n.line_intersects_circle(a, j))

    testing.expect(t, g4n.line_intersects_circle(b, k))

    testing.expect(t, !g4n.line_intersects_circle(c, l))
}
@(test)
lines_dist_test :: proc(t: ^testing.T) {
    a := g4n.ILine{{5,5}, {4,4}}
    b := g4n.ILine{{-2,0}, {7,1}}
    c := g4n.FLine{{-1.7,5.5}, {4.0, 5.6}}
    d := g4n.FLine{{-17.8,5.8}, {-4.0, -5.6}}
    e := g4n.TLine{{10, 10}, {2,2}}
    f := g4n.TLine{{10, 12}, {2,3}}
    g := g4n.TLine{{10, 11}, {2,3}}

    testing.expect_value(t, g4n.lines_distance(a,a), 0)
    testing.expect(t, abs(g4n.lines_distance(a,b) - math.sqrt_f32(10.9755878049)) < 0.0001)
    testing.expect(t, abs(g4n.lines_distance(c,d) - math.sqrt_f32(100.45056)) < 0.0001)
    testing.expect_value(t, g4n.lines_distance(e,f), math.sqrt_f32(0.5))
    testing.expect_value(t, g4n.lines_distance(f,g), 0)
}

@(test)
line_rect_dist_test :: proc(t: ^testing.T) {
    a := g4n.rect_from_nw_se(g4n.IVector{1, -4},   g4n.IVector{5, 10})
    b := g4n.rect_from_nw_se(g4n.FVector{-3,5.88}, g4n.FVector{-2,11.88})
    c := g4n.rect_from_nw_se(g4n.TVector{9,3},     g4n.TVector{11,6})

    d := g4n.ILine{{3, 12}, {3, -6}}
    e := g4n.ILine{{3, 9}, {3, 8}}
    f := g4n.ILine{{1, 10}, {5, 10}}
    g := g4n.ILine{{3, 15}, {3, 12}}
    
    h := g4n.FLine{{-5, 0}, {4, 10}}

    i := g4n.TLine{{0, 0}, {4, 10}}

    testing.expect_value(t, g4n.line_rectangle_distance(d, a), 0)
    testing.expect_value(t, g4n.line_rectangle_distance(e, a), 0)
    testing.expect_value(t, g4n.line_rectangle_distance(f, a), 0)
    testing.expect_value(t, g4n.line_rectangle_distance(g, a), 2)

    testing.expect(t, abs(g4n.line_rectangle_distance(h, b) - math.sqrt_f32(2.9022671609)) < 0.0001)

    testing.expect(t, abs(g4n.line_rectangle_distance(i, c) - math.sqrt_f32(37.5517696552)) < 0.0001)
}
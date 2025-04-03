package g4ntests
import sdl "vendor:sdl3"
import g4n "../../g4n"
import "core:math"
import "core:testing"

@(test)
circle_circumf_test :: proc(t: ^testing.T) {
    a := g4n.ICircle{0, 0, 1}
    b := g4n.FCircle{0, 0, 4.78}
    c := g4n.TCircle{0, 0, 10}

    testing.expect_value(t, g4n.get_circle_circumfrence(a), 2 * math.PI)
    testing.expect(t, abs(g4n.get_circle_circumfrence(b) - 9.56 * math.PI) < 0.0001)
    testing.expect(t, abs(g4n.get_circle_circumfrence(c) - 20 * math.PI) < 0.0001)
}

@(test)
circle_add_vec_test :: proc(t: ^testing.T) {
    a := g4n.ICircle{0, 0, 1}
    b := g4n.FCircle{0, 0, 4.78}
    c := g4n.TCircle{0, 0, 10}

    testing.expect_value(t, g4n.get_circle_position(g4n.circle_add_vector(a, g4n.IVECTOR_ZERO)), g4n.IVECTOR_ZERO)
    testing.expect_value(t, g4n.get_circle_position(g4n.circle_add_vector(b, g4n.FVector{4, -10.6})), g4n.FVector{4, -10.6})
    testing.expect_value(t, g4n.get_circle_position(g4n.circle_add_vector(c, g4n.TVector{1, 1})), g4n.TVector{1, 1})
}

@(test)
circle_vec_dist_test :: proc(t: ^testing.T) {
    a := g4n.ICircle{0, 0, 1}
    b := g4n.FCircle{0, 0, 4.78}
    c := g4n.TCircle{0, 0, 10}

    testing.expect_value(t, g4n.circle_vector_dist(a, g4n.IVECTOR_ZERO), 0)
    testing.expect_value(t, g4n.circle_vector_dist(a, g4n.IVector{0, 1}), 0)
    testing.expect_value(t, g4n.circle_vector_dist(a, g4n.IVector{0, 2}), 1)
    testing.expect(t, abs(g4n.circle_vector_dist(b, g4n.FVector{4, -10.6}) - math.sqrt_f32(128.36) + 4.78) < 0.0001)
    testing.expect_value(t, g4n.circle_vector_dist(c, g4n.TVector{10, 10}), math.sqrt_f32(200) - 10)
}

@(test)
circles_collide_test :: proc(t: ^testing.T) {
    a := g4n.ICircle{0, 0, 1}
    b := g4n.ICircle{7, 4, 6}
    c := g4n.ICircle{-1, -1, 4}

    d := g4n.FCircle{0, 0, 10}
    e := g4n.FCircle{20, 0, 10}
    f := g4n.FCircle{0, 0, 9.999}

    g := g4n.TCircle{4, 4, 1}
    h := g4n.TCircle{0, 0, 5}
    i := g4n.TCircle{0, 0, 1}

    testing.expect(t, !g4n.circles_collide(a, b))
    testing.expect(t, g4n.circles_collide(b, c))

    testing.expect(t, g4n.circles_collide(d, e))
    testing.expect(t, !g4n.circles_collide(e, f))

    testing.expect(t, g4n.circles_collide(g, h))
    testing.expect(t, g4n.circles_collide(h, i))
}

@(test)
circle_rect_dist_test :: proc(t: ^testing.T) {
    a := g4n.ICircle{0, -5, 3}
    b := g4n.FCircle{0, 0, 9.999}
    c := g4n.TCircle{4, 4, 1}

    d := g4n.IRect{0, -5, 1, 1}
    e := g4n.FRect{0, 15, 7, 11.01}
    f := g4n.TRect{6, 4, 2, 3}
    g := g4n.trect_from_nw_se({6, 1}, {7, 3})

    testing.expect_value(t, g4n.circle_rect_dist(a, d), 0)
    testing.expect_value(t, g4n.circle_rect_dist(b, e), 0)
    testing.expect_value(t, g4n.circle_rect_dist(c, f), 1)
    testing.expect_value(t, g4n.circle_rect_dist(c, g), 1.236068)
}

@(test)
circle_rect_collides_test :: proc(t: ^testing.T) {
    a := g4n.ICircle{0, -5, 3}
    b := g4n.FCircle{0, 0, 9.999}
    c := g4n.TCircle{4, 4, 1}

    d := g4n.IRect{0, -5, 1, 1}
    e := g4n.FRect{0, 15, 7, 11.01}
    f := g4n.TRect{6, 4, 2, 3}
    g := g4n.trect_from_nw_se({6, 1}, {7, 3})

    testing.expect(t, g4n.circle_collides_rect(a, d))
    testing.expect(t, g4n.circle_collides_rect(b, e))
    testing.expect(t, !g4n.circle_collides_rect(c, f))
    testing.expect(t, !g4n.circle_collides_rect(c, g))
}
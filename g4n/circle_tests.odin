package g4n
import sdl "vendor:sdl3"
import "core:testing"
import "core:math"

@(test)
circle_circumf_test :: proc(t: ^testing.T) {
    a := ICircle{0, 0, 1}
    b := FCircle{0, 0, 4.78}
    c := TCircle{0, 0, 10}

    testing.expect_value(t, get_circle_circumfrence(a), 2 * math.PI)
    testing.expect(t, abs(get_circle_circumfrence(b) - 9.56 * math.PI) < 0.0001)
    testing.expect(t, abs(get_circle_circumfrence(c) - 20 * math.PI) < 0.0001)
}

@(test)
circle_add_vec_test :: proc(t: ^testing.T) {
    a := ICircle{0, 0, 1}
    b := FCircle{0, 0, 4.78}
    c := TCircle{0, 0, 10}

    testing.expect_value(t, get_circle_position(circle_add_vector(a, IVECTOR_ZERO)), IVECTOR_ZERO)
    testing.expect_value(t, get_circle_position(circle_add_vector(b, FVector{4, -10.6})), FVector{4, -10.6})
    testing.expect_value(t, get_circle_position(circle_add_vector(c, TVector{1, 1})), TVector{1, 1})
}

@(test)
circle_vec_dist_test :: proc(t: ^testing.T) {
    a := ICircle{0, 0, 1}
    b := FCircle{0, 0, 4.78}
    c := TCircle{0, 0, 10}

    testing.expect_value(t, circle_vector_dist(a, IVECTOR_ZERO), 0)
    testing.expect_value(t, circle_vector_dist(a, IVector{0, 1}), 0)
    testing.expect_value(t, circle_vector_dist(a, IVector{0, 2}), 1)
    testing.expect(t, abs(circle_vector_dist(b, FVector{4, -10.6}) - math.sqrt_f32(128.36) + 4.78) < 0.0001)
    testing.expect_value(t, circle_vector_dist(c, TVector{10, 10}), math.sqrt_f32(200) - 10)
}

@(test)
circles_collide_test :: proc(t: ^testing.T) {
    a := ICircle{0, 0, 1}
    b := ICircle{7, 4, 6}
    c := ICircle{-1, -1, 4}

    d := FCircle{0, 0, 10}
    e := FCircle{20, 0, 10}
    f := FCircle{0, 0, 9.999}

    g := TCircle{4, 4, 1}
    h := TCircle{0, 0, 5}
    i := TCircle{0, 0, 1}

    testing.expect(t, !circles_collide(a, b))
    testing.expect(t, circles_collide(b, c))

    testing.expect(t, circles_collide(d, e))
    testing.expect(t, !circles_collide(e, f))

    testing.expect(t, circles_collide(g, h))
    testing.expect(t, circles_collide(h, i))
}

@(test)
circle_rect_dist_test :: proc(t: ^testing.T) {
    a := ICircle{0, -5, 3}
    b := FCircle{0, 0, 9.999}
    c := TCircle{4, 4, 1}

    d := IRect{0, -5, 1, 1}
    e := FRect{0, 15, 7, 11.01}
    f := TRect{6, 4, 2, 3}
    g := trect_from_nw_se({6, 1}, {7, 3})

    testing.expect_value(t, circle_rect_dist(a, d), 0)
    testing.expect_value(t, circle_rect_dist(b, e), 0)
    testing.expect_value(t, circle_rect_dist(c, f), 1)
    testing.expect_value(t, circle_rect_dist(c, g), 1.236068)
}

@(test)
circle_rect_collides_test :: proc(t: ^testing.T) {
    a := ICircle{0, -5, 3}
    b := FCircle{0, 0, 9.999}
    c := TCircle{4, 4, 1}

    d := IRect{0, -5, 1, 1}
    e := FRect{0, 15, 7, 11.01}
    f := TRect{6, 4, 2, 3}
    g := trect_from_nw_se({6, 1}, {7, 3})

    testing.expect(t, circle_collides_rect(a, d))
    testing.expect(t, circle_collides_rect(b, e))
    testing.expect(t, !circle_collides_rect(c, f))
    testing.expect(t, !circle_collides_rect(c, g))
}
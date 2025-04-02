package g4n
import sdl "vendor:sdl3"
import "core:testing"
import "core:math"

@(test)
vector_add_test :: proc(t: ^testing.T) {
    a := IVector{5,5}
    b := IVECTOR_ZERO
    c := IVector{-2,3}
    d := FVector{4.0, 5.5}
    e := TVector{10, 10}

    testing.expect_value(t, vector_add(a, b), a)
    testing.expect_value(t, vector_add(a, c), IVector{3,8})
    testing.expect_value(t, vector_add(a, to_ivector(d)), IVector{9,10})
    testing.expect_value(t, vector_add(d, to_fvector(a)), FVector{9.0,10.5})
    testing.expect_value(t, vector_add(e, to_tvector(a)), TVector{15,15})
}

@(test)
vector_mult_test :: proc(t: ^testing.T) {
    a := IVector{5,5}
    b := IVECTOR_ZERO
    c := FVector{4.0, 5.5}
    d := TVector{10, 10}

    x : i32 = -2
    y : f32 = 3.5
    z : u32 = 7

    testing.expect_value(t, vector_mult_scalar(a, x), IVector{-10,-10})
    testing.expect_value(t, vector_mult_scalar(b, x), b)
    testing.expect_value(t, vector_mult_scalar(c, y), FVector{14.0,19.25})
    testing.expect_value(t, vector_mult_scalar(d, z), TVector{70,70})
}

@(test)
vector_div_test :: proc(t: ^testing.T) {
    a := IVector{5,5}
    b := IVECTOR_ZERO
    c := FVector{4.0, 5.5}
    d := TVector{10, 10}

    x : i32 = -2
    y : f32 = 3.5
    z : u32 = 7

    testing.expect_value(t, vector_div_scalar(a, x), IVector{-2,-2})
    testing.expect_value(t, vector_div_scalar(b, x), b)
    testing.expect_value(t, vector_div_scalar(c, y), FVector{(4/3.5),(5.5/3.5)})
    testing.expect_value(t, vector_div_scalar(d, z), TVector{1,1})
}

@(test)
vector_cross_test :: proc(t: ^testing.T) {
    a := IVector{5,5}
    b := IVECTOR_ZERO
    c := FVector{4.0, 5.5}
    d := FVector{-1.8, 10.65}
    e := TVector{10, 10}
    f := TVector{1, 17}

    testing.expect_value(t, vector_cross(a, b), 0)
    testing.expect_value(t, vector_cross(a, to_ivector(c)), 5)
    testing.expect_value(t, vector_cross(c, d), 52.5)
    testing.expect_value(t, vector_cross(e, f), 160)
}

@(test)
vector_dist_test :: proc(t: ^testing.T) {
    a := IVector{5,5}
    b := IVECTOR_ZERO
    c := FVector{4.0, 5.5}
    d := FVector{-6, 10.5}
    e := TVector{10, 10}
    f := TVector{1, 17}

    testing.expect_value(t, vector_dist(a, b), math.sqrt_f32(50))
    testing.expect_value(t, vector_dist(c, to_fvector(a)), math.sqrt_f32(1.25))
    testing.expect_value(t, vector_dist(c, d), math.sqrt_f32(125))
    testing.expect_value(t, vector_dist(e, f), math.sqrt_f32(130))
}

@(test)
vector_normalize_test :: proc(t: ^testing.T) {
    a := IVector{5,5}
    b := FVector{-6, 10.5}
    c := TVector{1, 17}

    sqrtFfty := math.sqrt_f32(50)
    sqrtOfs := math.sqrt_f32(146.25)
    sqrtTnnty := math.sqrt_f32(290)

    testing.expect_value(t, vector_normalize(a), to_fvector(a) / sqrtFfty)
    testing.expect_value(t, vector_normalize(b), b / sqrtOfs)
    testing.expect_value(t, vector_normalize(c), to_fvector(c) / sqrtTnnty)
}
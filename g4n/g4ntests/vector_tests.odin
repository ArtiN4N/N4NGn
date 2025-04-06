package g4ntests
import sdl "vendor:sdl3"
import g4n "../../g4n"
import "core:math"
import "core:testing"

@(test)
vector_add_test :: proc(t: ^testing.T) {
    a := g4n.IVector{5,5}
    b := g4n.IVECTOR_ZERO
    c := g4n.IVector{-2,3}
    d := g4n.FVector{4.0, 5.5}
    e := g4n.TVector{10, 10}

    testing.expect_value(t, g4n.vector_add(a, b), a)
    testing.expect_value(t, g4n.vector_add(a, c), g4n.IVector{3,8})
    testing.expect_value(t, g4n.vector_add(a, g4n.to_ivector(d)), g4n.IVector{9,10})
    testing.expect_value(t, g4n.vector_add(d, g4n.to_fvector(a)), g4n.FVector{9.0,10.5})
    testing.expect_value(t, g4n.vector_add(e, g4n.to_tvector(a)), g4n.TVector{15,15})
}

@(test)
vector_sub_test :: proc(t: ^testing.T) {
    a := g4n.IVector{5,5}
    b := g4n.IVECTOR_ZERO
    c := g4n.IVector{-2,3}
    d := g4n.FVector{4.0, 5.5}
    e := g4n.TVector{10, 10}

    testing.expect_value(t, g4n.vector_sub(a, b), a)
    testing.expect_value(t, g4n.vector_sub(a, c), g4n.IVector{7,2})
    testing.expect_value(t, g4n.vector_sub(a, g4n.to_ivector(d)), g4n.IVector{1,0})
    testing.expect_value(t, g4n.vector_sub(d, g4n.to_fvector(a)), g4n.FVector{-1,0.5})
    testing.expect_value(t, g4n.vector_sub(e, g4n.to_tvector(a)), g4n.TVector{5,5})
}

@(test)
vector_abs_test :: proc(t: ^testing.T) {
    a := g4n.IVector{5,5}
    b := g4n.IVector{-2,3}
    c := g4n.FVector{-4.0, -5.5}

    testing.expect_value(t, g4n.vector_abs(a), a)
    testing.expect_value(t, g4n.vector_abs(b), g4n.IVector{2,3})
    testing.expect_value(t, g4n.vector_abs(c), g4n.FVector{4.0,5.5})
}

@(test)
floor_fvector_test :: proc(t: ^testing.T) {
    a := g4n.FVector{5,5.21}
    b := g4n.FVector{-2.999,3}
    c := g4n.FVector{-4.0, -5.5}

    testing.expect_value(t, g4n.floor_fvector(a), g4n.FVector{5,5})
    testing.expect_value(t, g4n.floor_fvector(b), g4n.FVector{-3, 3})
    testing.expect_value(t, g4n.floor_fvector(c), g4n.FVector{-4, -6})
}

@(test)
vector_mult_test :: proc(t: ^testing.T) {
    a := g4n.IVector{5,5}
    b := g4n.IVECTOR_ZERO
    c := g4n.FVector{4.0, 5.5}
    d := g4n.TVector{10, 10}

    x : i32 = -2
    y : f32 = 3.5
    z : u32 = 7

    testing.expect_value(t, g4n.vector_mult_scalar(a, x), g4n.IVector{-10,-10})
    testing.expect_value(t, g4n.vector_mult_scalar(b, x), b)
    testing.expect_value(t, g4n.vector_mult_scalar(c, y), g4n.FVector{14.0,19.25})
    testing.expect_value(t, g4n.vector_mult_scalar(d, z), g4n.TVector{70,70})
}

@(test)
vector_div_test :: proc(t: ^testing.T) {
    a := g4n.IVector{5,5}
    b := g4n.IVECTOR_ZERO
    c := g4n.FVector{4.0, 5.5}
    d := g4n.TVector{10, 10}

    x : i32 = -2
    y : f32 = 3.5
    z : u32 = 7

    testing.expect_value(t, g4n.vector_div_scalar(a, x), g4n.IVector{-2,-2})
    testing.expect_value(t, g4n.vector_div_scalar(b, x), b)
    testing.expect_value(t, g4n.vector_div_scalar(c, y), g4n.FVector{(4/3.5),(5.5/3.5)})
    testing.expect_value(t, g4n.vector_div_scalar(d, z), g4n.TVector{1,1})
}

@(test)
vector_cross_test :: proc(t: ^testing.T) {
    a := g4n.IVector{5,5}
    b := g4n.IVECTOR_ZERO
    c := g4n.FVector{4.0, 5.5}
    d := g4n.FVector{-1.8, 10.65}
    e := g4n.TVector{10, 10}
    f := g4n.TVector{1, 17}

    testing.expect_value(t, g4n.vector_cross(a, b), 0)
    testing.expect_value(t, g4n.vector_cross(a, g4n.to_ivector(c)), 5)
    testing.expect_value(t, g4n.vector_cross(c, d), 52.5)
    testing.expect_value(t, g4n.vector_cross(e, f), 160)
}

@(test)
vector_dist_test :: proc(t: ^testing.T) {
    a := g4n.IVector{5,5}
    b := g4n.IVECTOR_ZERO
    c := g4n.FVector{4.0, 5.5}
    d := g4n.FVector{-6, 10.5}
    e := g4n.TVector{10, 10}
    f := g4n.TVector{1, 17}

    testing.expect_value(t, g4n.vector_dist(a, b), math.sqrt_f32(50))
    testing.expect_value(t, g4n.vector_dist(c, g4n.to_fvector(a)), math.sqrt_f32(1.25))
    testing.expect_value(t, g4n.vector_dist(c, d), math.sqrt_f32(125))
    testing.expect_value(t, g4n.vector_dist(e, f), math.sqrt_f32(130))
}

@(test)
vector_normalize_test :: proc(t: ^testing.T) {
    a := g4n.IVector{5,5}
    b := g4n.FVector{-6, 10.5}
    c := g4n.TVector{1, 17}

    sqrtFfty := math.sqrt_f32(50)
    sqrtOfs := math.sqrt_f32(146.25)
    sqrtTnnty := math.sqrt_f32(290)

    testing.expect_value(t, g4n.vector_normalize(a), g4n.to_fvector(a) / sqrtFfty)
    testing.expect_value(t, g4n.vector_normalize(b), b / sqrtOfs)
    testing.expect_value(t, g4n.vector_normalize(c), g4n.to_fvector(c) / sqrtTnnty)
}
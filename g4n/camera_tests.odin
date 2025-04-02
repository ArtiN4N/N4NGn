package g4n
import sdl "vendor:sdl3"
import "core:testing"

@(test)
camera_anchor_tracking_test :: proc(t: ^testing.T) {
    anchor : IVector = IVECTOR_ZERO
    cam : Camera = create_camera(2, 2, &anchor)

    testing.expect_value(t, get_camera_real_position(cam), IVector{-1,-1})

    anchor.x += 1
    testing.expect_value(t, get_camera_real_position(cam), IVector{0,-1})

    anchor.y = -2
    testing.expect_value(t, get_camera_real_position(cam), IVector{0,-3})
}

@(test)
camera_rectangle_test :: proc(t: ^testing.T) {
    anchor : IVector = {-10,10}
    cam : Camera = create_camera(2, 2, &anchor, IVector{3,-4})

    testing.expect_value(t, get_camera_real_rectangle(cam), sdl.Rect{-8, 5, 2, 2})
}

@(test)
camera_contains_vector_test :: proc(t: ^testing.T) {
    anchor : IVector = IVECTOR_ZERO
    cam : Camera = create_camera(2, 2, &anchor)

    expect_vecs : [4]IVector = {
        IVECTOR_ZERO, {0,-1}, {-1,0}, {-1,-1}  
    }
    for vec in expect_vecs { testing.expect(t, is_point_in_camera(cam, vec)) }

    dont_expect_vecs : [2]IVector = {
        {1,0}, {-2,0}
    }
    for vec in dont_expect_vecs { testing.expect(t, !is_point_in_camera(cam, vec)) }
}

@(test)
camera_contains_rectangle_test :: proc(t: ^testing.T) {
    anchor : IVector = { 0, 0 }
    cam : Camera = create_camera(2, 2, &anchor)

    expect_rects : [4]sdl.Rect = {
        {0, 0, 2, 2},
        {-2, 0, 2, 2},
        {0, -2, 2, 2},
        {-2, -2, 2, 2},
    }
    for rect in expect_rects { testing.expect(t, is_rectangle_in_camera(cam, rect)) }


    dont_expect_rects : [2]sdl.Rect = {
        {1, 1, 2, 2},
        {-2, -2, 1, 1},
    }
    for rect in dont_expect_rects { testing.expect(t, !is_rectangle_in_camera(cam, rect)) }
}
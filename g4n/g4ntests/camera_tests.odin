package g4ntests
import sdl "vendor:sdl3"
import g4n "../../g4n"
import "core:testing"

@(test)
camera_anchor_tracking_test :: proc(t: ^testing.T) {
    anchor : g4n.IVector = g4n.IVECTOR_ZERO
    cam : g4n.Camera = g4n.create_camera(2, 2, &anchor)

    testing.expect_value(t, g4n.get_camera_anchored_position(cam), g4n.IVector{0, 0})

    anchor.x += 1
    testing.expect_value(t, g4n.get_camera_anchored_position(cam), g4n.IVector{1, 0})

    anchor.y = -2
    testing.expect_value(t, g4n.get_camera_anchored_position(cam), g4n.IVector{1, -2})
}

@(test)
camera_rectangle_test :: proc(t: ^testing.T) {
    anchor : g4n.IVector = {-10,10}
    cam : g4n.Camera = g4n.create_camera(2, 2, &anchor, g4n.IVector{3,-4})

    testing.expect_value(t, g4n.get_camera_anchored_rectangle(cam), sdl.Rect{-7, 6, 2, 2})
}

@(test)
camera_contains_vector_test :: proc(t: ^testing.T) {
    anchor : g4n.IVector = g4n.IVECTOR_ZERO
    cam : g4n.Camera = g4n.create_camera(3, 3, &anchor)

    a := g4n.IVECTOR_ZERO
    b := g4n.IVector{0,-1}
    c := g4n.IVector{-1,0}
    d := g4n.IVector{-1,-1}

    e := g4n.IVector{2,0}
    f := g4n.IVector{0,-2}

    testing.expect(t, g4n.is_point_in_camera(cam, a))
    testing.expect(t, g4n.is_point_in_camera(cam, b))
    testing.expect(t, g4n.is_point_in_camera(cam, c))
    testing.expect(t, g4n.is_point_in_camera(cam, d))

    testing.expect(t, !g4n.is_point_in_camera(cam, e))
    testing.expect(t, !g4n.is_point_in_camera(cam, f))
}

@(test)
camera_contains_rectangle_test :: proc(t: ^testing.T) {
    anchor := g4n.IVECTOR_ZERO
    cam : g4n.Camera = g4n.create_camera(11, 11, &anchor)


    a := g4n.IRect{0, 0, 12, 12}
    b := g4n.IRect{6, 0, 3, 2}

    c := g4n.IRect{6, 0, 1, 1}

    testing.expect(t, g4n.is_rectangle_in_camera(cam, a))
    testing.expect(t, g4n.is_rectangle_in_camera(cam, b))

    testing.expect(t, !g4n.is_rectangle_in_camera(cam, c))
}
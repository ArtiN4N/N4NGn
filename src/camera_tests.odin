package main
import sdl "vendor:sdl3"
import "core:testing"

@(test)
camera_anchor_tracking_test :: proc(t: ^testing.T) {
    anchor : sdl.Point = POINT_ZERO
    cam : Camera = create_camera(2, 2, &anchor)

    testing.expect_value(t, get_camera_real_position(cam), sdl.Point{-1,-1})

    anchor.x += 1
    testing.expect_value(t, get_camera_real_position(cam), sdl.Point{0,-1})

    anchor.y = -2
    testing.expect_value(t, get_camera_real_position(cam), sdl.Point{0,-3})
}

@(test)
camera_rectangle_test :: proc(t: ^testing.T) {
    anchor : sdl.Point = {-10,10}
    cam : Camera = create_camera(2, 2, &anchor, sdl.Point{3,-4})

    testing.expect_value(t, get_camera_real_rectangle(cam), sdl.Rect{-8, 5, 2, 2})
}

@(test)
camera_contains_point_test :: proc(t: ^testing.T) {
    anchor : sdl.Point = POINT_ZERO
    cam : Camera = create_camera(2, 2, &anchor)

    expect_points : [4]sdl.Point = {
        POINT_ZERO, {0,-1}, {-1,0}, {-1,-1}  
    }
    for point in expect_points { testing.expect(t, is_point_in_camera(cam, point)) }

    dont_expect_points : [2]sdl.Point = {
        {1,0}, {-2,0}
    }
    for point in dont_expect_points { testing.expect(t, !is_point_in_camera(cam, point)) }
}

@(test)
camera_contains_rectangle_test :: proc(t: ^testing.T) {
    anchor : sdl.Point = { 0, 0 }
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
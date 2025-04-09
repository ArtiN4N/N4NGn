package g4ntests
import sdl "vendor:sdl3"
import g4n "../../g4n"
import "core:testing"

@(test)
get_real_physics_body_rect_test :: proc(t: ^testing.T) {
    pos := g4n.FVector{0, 0}
    pb := g4n.make_physics_body(&pos, 0, 0, 10, 10)

    testing.expect_value(t, g4n.get_real_physics_body_rect(pb), g4n.FRect{0, 0, 10, 10})
    pos.x += 10.7
    testing.expect_value(t, g4n.get_real_physics_body_rect(pb), g4n.FRect{10.7, 0, 10, 10})
}
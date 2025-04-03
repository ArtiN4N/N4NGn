package g4ntests
import sdl "vendor:sdl3"
import g4n "../../g4n"
import "core:testing"

@(test)
timer_tests :: proc(t: ^testing.T) {
    gc := g4n.create_game_clock()
    gc.dt = 0.5

    timer := g4n.create_timer()
    testing.expect_value(t, timer.elapsed, 0)

    g4n.update_timer(&timer, gc)
    testing.expect_value(t, timer.elapsed, 0)

    g4n.start_timer(&timer)
    g4n.update_timer(&timer, gc)
    g4n.update_timer(&timer, gc)
    g4n.stop_timer(&timer)
    g4n.update_timer(&timer, gc)
    testing.expect_value(t, timer.elapsed, 1.0)

    g4n.reset_timer(&timer)
    testing.expect_value(t, timer.elapsed, 0)
}
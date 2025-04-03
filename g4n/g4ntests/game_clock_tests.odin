package g4ntests
import sdl "vendor:sdl3"
import g4n "../../g4n"
import "core:testing"

@(test)
deltatime_average_test :: proc(t: ^testing.T) {
    clock := g4n.create_game_clock()
    clock.timesteps = {
        7.0, 10.0, 5.0, -2.0, 5.5, 21.3, 0.1, 3.8, 11.0, 14.22
    }

    testing.expect_value(t, g4n.get_deltatime(clock), 7.592)
}
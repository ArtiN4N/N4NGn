package main
import sdl "vendor:sdl3"
import "core:testing"

@(test)
deltatime_average_test :: proc(t: ^testing.T) {
    clock := create_game_clock()
    clock.timesteps = {
        7.0, 10.0, 5.0, -2.0, 5.5, 21.3, 0.1, 3.8, 11.0, 14.22
    }

    testing.expect_value(t, get_deltatime(clock), 7.592)
}
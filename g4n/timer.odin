package g4n

import sdl "vendor:sdl3"

import "core:log"

Timer :: struct {
    elapsed: f32,
    active: bool,
}

create_timer :: proc() -> (timer: Timer) {
    timer.elapsed = 0
    timer.active = false

    log.logf(.Debug, "Created timer.")
    return
}

update_timer :: proc(timer: ^Timer, game_clock: Game_Clock) {
    if !timer.active { return }
    timer.elapsed += game_clock.dt
}

stop_timer :: proc(timer: ^Timer) { timer.active = false }

start_timer :: proc(timer: ^Timer) { timer.active = true }

reset_timer :: proc(timer: ^Timer) { timer.elapsed = 0 }
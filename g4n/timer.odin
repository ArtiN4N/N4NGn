package g4n
import sdl "vendor:sdl3"

Timer :: struct {
    elapsed: f32,
    active: bool,
}

create_timer :: proc() -> (timer: Timer) {
    timer.elapsed = 0
    timer.active = false
    return
}

update_timer :: proc(timer: ^Timer, game_clock: GameClock) {
    if !timer.active { return }
    timer.elapsed += game_clock.dt
}

stop_timer :: proc(timer: ^Timer) { timer.active = false }

start_timer :: proc(timer: ^Timer) { timer.active = true }

reset_timer :: proc(timer: ^Timer) { timer.elapsed = 0 }
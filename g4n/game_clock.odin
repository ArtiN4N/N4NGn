package g4n

import sdl "vendor:sdl3"

import "core:log"

DEFAULT_DT :: 0.01
TIMESTEP_AVERAGE_COUNT :: 10

// Simple struct to handle game-wide time concerns like dt and uptime.
Game_Clock :: struct {
	// An array of 10 values for timesteps. Allows a rolling average to be used for dt.
	// This theoretically makes physics smoother during times of slight frame flucuation.
	timesteps: [TIMESTEP_AVERAGE_COUNT]f32,
	timesteps_idx: uint,

	dt: f32,
	last_ticks: u64,
}

// Warning: This proc happens before SDL is init
create_game_clock :: proc() -> (clock: Game_Clock){
	clock.timesteps = { DEFAULT_DT, DEFAULT_DT, DEFAULT_DT, DEFAULT_DT, DEFAULT_DT, DEFAULT_DT, DEFAULT_DT, DEFAULT_DT, DEFAULT_DT, DEFAULT_DT }
	clock.timesteps_idx = 0
	clock.dt = DEFAULT_DT
	clock.last_ticks = 0

	log.logf(.Info, "Created game clock.")
	return
}

update_timesteps :: proc(clock: ^Game_Clock) {
	// Current frame deltatime calculation
	if (clock.last_ticks == 0) { clock.last_ticks = sdl.GetPerformanceCounter() }
	current_ticks := sdl.GetPerformanceCounter()
	timestep : u64 = current_ticks - clock.last_ticks
	clock.last_ticks = current_ticks
	
	// store it so we can do moving average for physics deltatime
	clock.timesteps[clock.timesteps_idx] = f32(timestep) / f32(sdl.GetPerformanceFrequency())

	// ensure valid index
	clock.timesteps_idx += 1
	if clock.timesteps_idx >= TIMESTEP_AVERAGE_COUNT { clock.timesteps_idx = 0 }

	clock.dt = get_delta_time(clock^)
}

get_delta_time :: proc(clock: Game_Clock) -> f32 {
	sum : f32 = 0.0
	for step in clock.timesteps { sum += step }
	return sum / TIMESTEP_AVERAGE_COUNT
}

get_uptime :: proc() -> f32 {
	// Divide by 1000 to convert to seconds
	return f32(sdl.GetTicks()) / 1000.0
}

get_fps :: proc(clock: Game_Clock) -> int {
	return int(1 / clock.dt)
}
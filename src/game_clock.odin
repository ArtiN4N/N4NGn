package main

import "core:fmt"
import "core:os"
import "core:strings"
import sdl "vendor:sdl3"

DEFAULT_DT :: 0.01
TIMESTEP_AVERAGE_COUNT :: 10

// Simple struct to handle game-wide time concerns like dt and uptime.
GameClock :: struct {
	fps: int,

	// An array of 10 values for timesteps. Allows a rolling average to be used for dt.
	// This theoretically makes physics smoother during times of slight frame flucuation.
	timesteps: [TIMESTEP_AVERAGE_COUNT]f32,
	timestepsIndex: uint,

	dt: f32,
	lastTicks: u64,
}

// Warning: This proc happens before SDL is init
create_game_clock :: proc() -> (clock: GameClock){
	clock.fps = 0
	clock.timesteps = { DEFAULT_DT, DEFAULT_DT, DEFAULT_DT, DEFAULT_DT, DEFAULT_DT, DEFAULT_DT, DEFAULT_DT, DEFAULT_DT, DEFAULT_DT, DEFAULT_DT }
	clock.timestepsIndex = 0
	clock.dt = DEFAULT_DT
	clock.lastTicks = 0

	log("Created game clock.")

	return
}

update_timesteps :: proc(clock: ^GameClock) {
	// Current frame deltatime calculation
	if (clock.lastTicks == 0) { clock.lastTicks = sdl.GetPerformanceCounter() }
	currentTicks := sdl.GetPerformanceCounter()
	timestep : u64 = currentTicks - clock.lastTicks
	clock.lastTicks = currentTicks
	
	// store it so we can do moving average for physics deltatime
	clock.timesteps[clock.timestepsIndex] = (cast(f32) timestep) / (cast(f32) sdl.GetPerformanceFrequency())

	// ensure valid index
	clock.timestepsIndex += 1
	if clock.timestepsIndex >= TIMESTEP_AVERAGE_COUNT { clock.timestepsIndex = 0 }
}

get_deltatime :: proc(clock: GameClock) -> f32 {
	sum : f32 = 0.0
	for step in clock.timesteps { sum += step }
	return sum / TIMESTEP_AVERAGE_COUNT
}

get_uptime :: proc() -> f32 {
	// Divide by 1000 to convert to seconds
	return (cast(f32) sdl.GetTicks()) / 1000.0
}
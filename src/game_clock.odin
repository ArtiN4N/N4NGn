package main

import "core:fmt"
import "core:os"
import "core:strings"
import sdl "vendor:sdl3"

GameClock :: struct {
	fps: int,
	timesteps: [10]f32,
	timestepsIndex: uint,
	dt: f32,
	lastTicks: u64,
	
}

// Happens before SDL is init
init_game_clock :: proc(gc: ^GameClock) {
	gc.fps = 1
	gc.timesteps = {}
	gc.timestepsIndex = 0
	gc.dt = 0.001
	gc.lastTicks = 0
}

update_timesteps :: proc(timing: ^GameClock) {
	// Current frame deltatime calculation
	currentTicks := sdl.GetPerformanceCounter()
	timestep : u64 = currentTicks - timing.lastTicks
	timing.lastTicks = currentTicks
	
	// store it so we can do moving average for physics deltatime
	timing.timesteps[timing.timestepsIndex] = (cast(f32) timestep) / (cast(f32) sdl.GetPerformanceFrequency())

	// ensure valid index
	timing.timestepsIndex += 1
	if timing.timestepsIndex >= 10 { timing.timestepsIndex = 0 }
}

get_deltatime :: proc(timing: GameClock) -> f32 {
	sum : f32 = 0.0
	for step in timing.timesteps { sum += step }
	return sum / 10.0
}

get_uptime :: proc() -> f32 {
	return (cast(f32) sdl.GetTicks()) / 1000.0
}
package main

import "core:fmt"
import "core:strings"

import rl "vendor:raylib"

main :: proc() {
    state := initialState()
    defer destroyState(&state)

    rl.InitWindow(state.windowSize.x, state.windowSize.y, "storymap")
    defer rl.CloseWindow()

    rl.SetExitKey(.KEY_NULL)
    rl.SetTargetFPS(30)

    for !rl.WindowShouldClose() && state.active {
        rl.BeginDrawing()
        defer rl.EndDrawing()

        rl.ClearBackground(rl.RAYWHITE)
        rl.DrawFPS(10, 10)
    }
}
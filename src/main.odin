package main

import "core:fmt"
import "core:strings"

import rl "vendor:raylib"

WINDOW_WIDTH :: 800
WINDOW_HEIGHT :: 800

main :: proc() {
    rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "n4ngn")
    defer rl.CloseWindow()

    rl.SetExitKey(.KEY_NULL)
    rl.SetTargetFPS(30)

    for !rl.WindowShouldClose() {
        rl.BeginDrawing()
        defer rl.EndDrawing()

        rl.ClearBackground(rl.RAYWHITE)
    }
}
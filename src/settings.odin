package main

import "core:fmt"
import "core:strings"
import "core:math"

import rl "vendor:raylib"

Settings :: struct {
    exit : bool,
    showEval : bool,
    showCaptures : bool,
}

initSettings :: proc() -> Settings {
    return Settings{
        false,
        false,
        true,
    }
}

drawSettingsGear :: proc() {
    // gear ring
    margin : f32 = 20
    gearRad : f32 = 10
    gearPosition := rl.Vector2{ WINDOW_WIDTH - gearRad - margin, gearRad + margin }
    gearInnerRad : f32 = 4
    gearSegments : i32 = 20
    rl.DrawRing(gearPosition, gearInnerRad, gearRad, 0, 360, gearSegments, rl.BLACK)

    // gear stubs
    for x : f32 = 0; x < 360; x += 45 {
        rad : f32 = math.PI * x / 180
        rec := rl.Rectangle{ gearPosition.x + math.cos(rad) * gearRad, gearPosition.y + math.sin(rad) * gearRad, gearRad / 2, gearRad / 2}
        rl.DrawRectanglePro(rec, rl.Vector2{ rec.width / 2, rec.height / 2 }, x, rl.BLACK)
    }
}
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

GEAR_RAD :: 10
GEAR_MARGIN :: 10
GEAR_P :: GEAR_RAD + GEAR_MARGIN

isSettingsGearClicked :: proc() -> bool {
    if !rl.IsMouseButtonDown(rl.MouseButton.LEFT) {
        return false
    }

    mousePos := rl.GetMousePosition()
    clickMargin : f32 = 5

    xInBounds := mousePos.x >= GEAR_P - GEAR_RAD - clickMargin && mousePos.x <= GEAR_P + GEAR_RAD + clickMargin
    yInBounds := mousePos.y >= GEAR_P - GEAR_RAD - clickMargin && mousePos.y <= GEAR_P + GEAR_RAD + clickMargin

    return xInBounds && yInBounds
}

drawSettingsGear :: proc() {
    // gear ring
    gearPosition := rl.Vector2{ GEAR_P, GEAR_P }
    gearInnerRad : f32 = 4
    gearSegments : i32 = 20
    rl.DrawRing(gearPosition, gearInnerRad, GEAR_RAD, 0, 360, gearSegments, rl.BLACK)

    // gear stubs
    for x : f32 = 0; x < 360; x += 45 {
        rad : f32 = math.PI * x / 180
        rec := rl.Rectangle{ gearPosition.x + math.cos(rad) * GEAR_RAD, gearPosition.y + math.sin(rad) * GEAR_RAD, GEAR_RAD / 2, GEAR_RAD / 2}
        rl.DrawRectanglePro(rec, rl.Vector2{ rec.width / 2, rec.height / 2 }, x, rl.BLACK)
    }
}
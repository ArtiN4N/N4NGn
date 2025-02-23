package main

import "core:fmt"
import "core:strings"
import "core:math"

import rl "vendor:raylib"

Settings :: struct {
    exit : bool,
    menuOpen : bool,
    showEval : bool,
    showCaptures : bool,

    openTimer : f32,
}

initSettings :: proc() -> Settings {
    return Settings{
        false,
        false,
        false,
        true,
    }
}

GEAR_RAD :: 10
GEAR_MARGIN :: 10
GEAR_P :: GEAR_RAD + GEAR_MARGIN

isSettingsGearClicked :: proc() -> bool {
    if !rl.IsMouseButtonPressed(rl.MouseButton.LEFT) {
        return false
    }

    mousePos := rl.GetMousePosition()
    clickMargin : f32 = 5

    xInBounds := mousePos.x >= GEAR_P - GEAR_RAD - clickMargin && mousePos.x <= GEAR_P + GEAR_RAD + clickMargin
    yInBounds := mousePos.y >= GEAR_P - GEAR_RAD - clickMargin && mousePos.y <= GEAR_P + GEAR_RAD + clickMargin

    return xInBounds && yInBounds
}

drawSettingsGear :: proc(settings : Settings) {
    offsetRot : f32 = 0

    gearColor := rl.BLACK

    if settings.menuOpen {
        offsetRot = 22
    }

    // gear ring
    gearPosition := rl.Vector2{ GEAR_P, GEAR_P }
    gearInnerRad : f32 = 4
    gearSegments : i32 = 20
    rl.DrawRing(gearPosition, gearInnerRad, GEAR_RAD, 0, 360, gearSegments, gearColor)

    // gear stubs
    for x : f32 = 0 + offsetRot; x < 360 + offsetRot; x += 45 {
        rad : f32 = math.PI * x / 180
        rec := rl.Rectangle{ gearPosition.x + math.cos(rad) * GEAR_RAD, gearPosition.y + math.sin(rad) * GEAR_RAD, GEAR_RAD / 2, GEAR_RAD / 2}
        rl.DrawRectanglePro(rec, rl.Vector2{ rec.width / 2, rec.height / 2 }, x, gearColor)
    }
}

drawSettingsMenu :: proc(settings : Settings) {
    outline := rl.Rectangle{ 0, 0, 300, 400 }
    rl.DrawRectangleRec(outline, rl.BLACK)

    box := rl.Rectangle{ 4, 4, 292, 392 }
    rl.DrawRectangleRec(box, rl.RAYWHITE)
}
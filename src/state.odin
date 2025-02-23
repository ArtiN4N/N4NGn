package main

import "core:fmt"
import "core:strings"

import rl "vendor:raylib"

State :: struct {
    settings : Settings,
    gameClock : Clock,
}

initState :: proc() -> State {
    return State{
        initSettings(),
        Clock{}
    }
}
package main

import "core:fmt"
import "core:strings"

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
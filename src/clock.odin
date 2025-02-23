package main

import "core:fmt"
import "core:strings"

import rl "vendor:raylib"

Clock :: struct {
    active : bool,
    whiteTime : f32,
    blackTime : f32,
    increment : u8,
}
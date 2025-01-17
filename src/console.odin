package main

import "core:fmt"
import "core:strings"

import rl "vendor:raylib"

Console :: struct {
    input: strings.Builder,
}
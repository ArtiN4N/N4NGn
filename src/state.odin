package main

import "core:fmt"
import "core:strings"

import rl "vendor:raylib"

DEFAULT_WINDOW_SIZE :: Vector2i{ 400, 400 }

// Struct that contains variables relevant to the "state" of the application as a whole.
// Contains all variable information about the game, meaning that any behaviour can be achieved, as long as there is access to the state .
State :: struct {
    console: Console,
    active: bool,
    windowSize: Vector2i,
}

// Procedure that initializes the state.
// The state contains allocated memory, which must be free'd at some point.
initialState :: proc() -> State {
    return {
        console = createConsole(),
        active = true,
        windowSize = DEFAULT_WINDOW_SIZE,
    }
}

// Procedure that destroys the state, along with any allocated memory assigned to it.
destroyState :: proc(state: ^State) {
    destroyConsole(&state.console)
}
package main

import "core:fmt"
import "core:strings"

import rl "vendor:raylib"

// Struct that contains variables relevant to a "console".
// A console is a place the user can type commands in to mess with the state of the running program.
// Contains a string builder, which must be allocated and subsequently free'd.
Console :: struct {
    input: strings.Builder,
    cursor: int,
    open: bool,
}

// Procedure that creates a console.
// Allocates memory for a console input string.
// This allocated memory must at some point be free'd.
createConsole :: proc() -> Console  {
    return {
        input = strings.builder_make(),
        cursor = 0,
        open = false,
    }
}

// Procedure that destroys a console, along with its allocated input memory.
destroyConsole :: proc(console: ^Console) {
    strings.builder_destroy(&console.input)
}

// Procedure that sets a console's open status to a particular value.
// Value defaults to true
setConsoleOpen :: proc(console: ^Console, status: bool = true) {
    console.open = status
}

// Procedure that handles adding a character to console input.
addCharacterToConsole :: proc(console: ^Console, character: u8) -> bool {
    // Failure if console is not open.
    if ! console.open {
        return false
    }

    // Grab a pointer to the buffer of the console's input.
    buf := &console.input.buf

    // Failure if console cursor is out of bounds.
    if console.cursor < 0 || console.cursor > len(buf) {
        return false
    }

    // Inject the character into the input buffer.
    inject_at(buf, console.cursor, character)

    return true
}

// Procedure that handles removing a character from console input.
removeCharacterFromConsole :: proc(console: ^Console) -> bool {
    // Failure if console is not open.
    if ! console.open {
        return false
    }

    // Grab a pointer to the buffer of the console's input.
    buf := &console.input.buf

    // Failure if console cursor is out of bounds, or if buffer has no characters.
    if console.cursor <= 0 || console.cursor > len(buf) || len(buf) == 0 {
        return false
    }

    // Grab the raw bytes via slices of the buffer.
    bytes1 := buf[0 : console.cursor - 1]
    bytes2 := buf[console.cursor : len(buf)]

    // Reset the console input.
    strings.builder_reset(&console.input)

    // Write the raw bytes sans the removed character back into the console input.
    strings.write_bytes(&console.input, bytes1)
    strings.write_bytes(&console.input, bytes2)

    return true
}

// Procecure that grabs a consoles current input as a string.
grabConsoleCommand :: proc(console: ^Console) -> string {
    return strings.to_string(console.input)
}
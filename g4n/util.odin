package g4n

import sdl "vendor:sdl3"


round_decimals :: proc(decs : ..^f32) {
    for &dec in decs {
        dec^ = cast(f32) (cast(int) dec^)
    }
}
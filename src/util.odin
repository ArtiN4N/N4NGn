package main

Vector2f :: [2]f32
Vector2i :: [2]i32
Vector2u :: [2]u32

round_decimals :: proc(decs : ..^f32) {
    for &dec in decs {
        dec^ = cast(f32) (cast(int) dec^)
    }
}
package g4ntests
import sdl "vendor:sdl3"
import g4n "../../g4n"
import "core:testing"

@(test)
test_load_map_from_file :: proc(t: ^testing.T) {
    tmap := g4n.load_map_from_file("tests/01.txt", 50)
    defer g4n.destroy_tile_map(&tmap)

    testing.expect_value(t, tmap.width_tiles, 8)
    testing.expect_value(t, tmap.height_tiles, 9)
    testing.expect_value(t, tmap.tile_size, 50)

    y_1_set : []g4n.Tile = {.WALL, .BLANK, .BLANK, .BLANK, .BLANK, .WALL, .BLANK, .WALL}
    y_4_set : []g4n.Tile = {.WALL, .BLANK, .BLANK, .BLANK, .BLANK, .WALL, .BLANK, .WALL}
    y_7_set : []g4n.Tile = {.WALL, .WALL, .WALL, .WALL, .WALL, .WALL, .WALL, .WALL}
    for i in 0..<tmap.width_tiles {
        testing.expect_value(t, tmap.set[i][1], y_1_set[i])
        testing.expect_value(t, tmap.set[i][4], y_4_set[i])
        testing.expect_value(t, tmap.set[i][7], y_7_set[i])
    }
}
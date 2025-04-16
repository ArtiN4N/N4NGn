package g4ntests
import sdl "vendor:sdl3"
import g4n "../../g4n"
import "core:testing"

@(test)
test_convert_position_to_map_index :: proc(t: ^testing.T) {
    a := g4n.to_tvector(g4n.FVector{75, 81.32})

    testing.expect_value(t, g4n.convert_position_to_map_index(a, 1), g4n.TVector{75, 81})
    testing.expect_value(t, g4n.convert_position_to_map_index(a, 50), g4n.TVector{1, 1})
    testing.expect_value(t, g4n.convert_position_to_map_index(a, 22), g4n.TVector{3, 3})
}

@(test)
test_get_map_indecies_bound_by_positions :: proc(t: ^testing.T) {
    a := g4n.to_tvector(g4n.FVector{75, 81.32})
    b := g4n.to_tvector(g4n.FVector{125, 81.32})
    c := g4n.to_tvector(g4n.FVector{125, 131.32})
    d := g4n.to_tvector(g4n.FVector{75, 131.32})

    mi_a, ma_a := g4n.get_map_indecies_bound_by_positions(a, c, 50)
    mi_b, ma_b := g4n.get_map_indecies_bound_by_positions(b, d, 50)
    mi_c, ma_c := g4n.get_map_indecies_bound_by_positions(c, d, 50)

    testing.expect_value(t, mi_a, g4n.TVector{1, 1})
    testing.expect_value(t, ma_a, g4n.TVector{2, 2})
    testing.expect_value(t, mi_b, g4n.TVector{1, 1})
    testing.expect_value(t, ma_b, g4n.TVector{2, 2})
    testing.expect_value(t, mi_c, g4n.TVector{1, 2})
    testing.expect_value(t, ma_c, g4n.TVector{2, 2})
}

@(test)
test_get_map_index_rect :: proc(t: ^testing.T) {
    a := g4n.TVector{1, 1}
    b := g4n.TVector{6, 1}
    c := g4n.TVector{6, 11}
    d := g4n.TVector{1, 11}

    testing.expect_value(t, g4n.get_map_index_rect(a.x, a.y, 20), g4n.TRect{29, 29, 20, 20})
    testing.expect_value(t, g4n.get_map_index_rect(b.x, b.y, 20), g4n.TRect{129, 29, 20, 20})
    testing.expect_value(t, g4n.get_map_index_rect(c.x, c.y, 20), g4n.TRect{129, 229, 20, 20})
    testing.expect_value(t, g4n.get_map_index_rect(d.x, d.y, 20), g4n.TRect{29, 229, 20, 20})
}

@(test)
test_tile_out_of_bounds :: proc(t: ^testing.T) {
    tmap := g4n.load_map_from_file("tests/01.txt", 50)
    defer g4n.destroy_tile_map(&tmap)

    testing.expect_value(t, tmap.width_tiles, 8)
    testing.expect_value(t, tmap.height_tiles, 9)
    testing.expect_value(t, tmap.tile_size, 50)
}
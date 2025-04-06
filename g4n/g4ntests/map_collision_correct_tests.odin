package g4ntests
import sdl "vendor:sdl3"
import g4n "../../g4n"
import "core:testing"
import olog "core:log"

@(test)
test_rect_movement_collision_correct_map :: proc(t: ^testing.T) {
    tmap := g4n.load_map_from_file("tests/01.txt", 1)
    defer g4n.destroy_tilemap(&tmap)

    tinfo := g4n.create_tile_info()

    rect_1 := g4n.TRect{3, 1, 1, 1}
    pos_1 := g4n.TVector{6, 1}
    c_pos_1, col_x_1, col_y_1 := g4n.tilemap_increment_rect_collision_correction(rect_1, pos_1, tmap, tinfo, g4n.NORMAL_ENTITY_COLLISION_TIER)
    testing.expect_value(t, c_pos_1, g4n.TVector{4, 1})
    testing.expect(t,       col_x_1)
    testing.expect(t,      !col_y_1)

    rect_2 := g4n.TRect{3, 1, 1, 1}
    pos_2 := g4n.TVector{5, 1}
    c_pos_2, col_x_2, col_y_2 := g4n.tilemap_increment_rect_collision_correction(rect_2, pos_2, tmap, tinfo, g4n.NORMAL_ENTITY_COLLISION_TIER)
    testing.expect_value(t, c_pos_2, g4n.TVector{4, 1})
    testing.expect(t,       col_x_2)
    testing.expect(t,      !col_y_2)

    rect_3 := g4n.TRect{6, 1, 1, 1}
    pos_3 := g4n.TVector{3, 1}
    c_pos_3, col_x_3, col_y_3 := g4n.tilemap_increment_rect_collision_correction(rect_3, pos_3, tmap, tinfo, g4n.NORMAL_ENTITY_COLLISION_TIER)
    testing.expect_value(t, c_pos_3, g4n.TVector{6, 1})
    testing.expect(t,       col_x_3)
    testing.expect(t,      !col_y_3)

    rect_4 := g4n.TRect{6, 6, 1, 1}
    pos_4 := g4n.TVector{6, 3}
    c_pos_4, col_x_4, col_y_4 := g4n.tilemap_increment_rect_collision_correction(rect_4, pos_4, tmap, tinfo, g4n.NORMAL_ENTITY_COLLISION_TIER)
    testing.expect_value(t, c_pos_4, g4n.TVector{6, 6})
    testing.expect(t,      !col_x_4)
    testing.expect(t,       col_y_4)
    
    rect_5 := g4n.TRect{6, 3, 1, 1}
    pos_5 := g4n.TVector{6, 6}
    c_pos_5, col_x_5, col_y_5 := g4n.tilemap_increment_rect_collision_correction(rect_5, pos_5, tmap, tinfo, g4n.NORMAL_ENTITY_COLLISION_TIER)
    testing.expect_value(t, c_pos_5, g4n.TVector{6, 4})
    testing.expect(t,      !col_x_5)
    testing.expect(t,       col_y_5)

    rect_6 := g4n.TRect{6, 6, 1, 1}
    pos_6 := g4n.TVector{1, 1}
    c_pos_6, col_x_6, col_y_6 := g4n.tilemap_increment_rect_collision_correction(rect_6, pos_6, tmap, tinfo, g4n.NORMAL_ENTITY_COLLISION_TIER)
    testing.expect_value(t, c_pos_6, g4n.TVector{1, 6})
    testing.expect(t,      !col_x_6)
    testing.expect(t,       col_y_6)
}
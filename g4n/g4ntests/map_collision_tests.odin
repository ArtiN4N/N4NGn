package g4ntests
import sdl "vendor:sdl3"
import g4n "../../g4n"
import "core:testing"

@(test)
test_line_collides_map :: proc(t: ^testing.T) {
    tmap := g4n.load_map_from_file("tests/01.txt", 50)
    defer g4n.destroy_tilemap(&tmap)

    tinfo := g4n.create_tile_info()

    line_1 := g4n.to_tline(g4n.FLine{{0, 0}, {1, 0}})
    line_2 := g4n.to_tline(g4n.FLine{{0, 51}, {50, 50}})
    line_3 := g4n.to_tline(g4n.FLine{{50, 50}, {51, 51}})
    line_4 := g4n.to_tline(g4n.FLine{{50, 50}, {320, 50}})
    line_5 := g4n.to_tline(g4n.FLine{{100, 100}, {310, 210}})
    line_6 := g4n.to_tline(g4n.FLine{{100, 100}, {210, 210}})

    testing.expect(t,  g4n.line_collides_map(line_1, tmap, tinfo, g4n.NORMAL_ENTITY_COLLISION_TIER))
    testing.expect(t,  g4n.line_collides_map(line_2, tmap, tinfo, g4n.NORMAL_ENTITY_COLLISION_TIER))
    testing.expect(t, !g4n.line_collides_map(line_3, tmap, tinfo, g4n.NORMAL_ENTITY_COLLISION_TIER))
    testing.expect(t,  g4n.line_collides_map(line_4, tmap, tinfo, g4n.NORMAL_ENTITY_COLLISION_TIER))
    testing.expect(t,  g4n.line_collides_map(line_5, tmap, tinfo, g4n.NORMAL_ENTITY_COLLISION_TIER))
    testing.expect(t, !g4n.line_collides_map(line_6, tmap, tinfo, g4n.NORMAL_ENTITY_COLLISION_TIER))
}

@(test)
test_rect_collides_map :: proc(t: ^testing.T) {
    tmap := g4n.load_map_from_file("tests/01.txt", 50)
    defer g4n.destroy_tilemap(&tmap)

    tinfo := g4n.create_tile_info()

    rect_1 := g4n.to_trect(g4n.FRect{0, 0, 1, 1})
    rect_2 := g4n.to_trect(g4n.FRect{49.5, 49.5, 50, 50})
    rect_3 := g4n.to_trect(g4n.FRect{50, 50, 1, 1})
    rect_4 := g4n.to_trect(g4n.FRect{199.5, 224.5, 400, 450})
    rect_5 := g4n.to_trect(g4n.FRect{274.5, 199.5, 150, 100})
    rect_6 := g4n.to_trect(g4n.FRect{149.5, 199.5, 200, 300})

    testing.expect(t,  g4n.rect_collides_map(rect_1, tmap, tinfo, g4n.NORMAL_ENTITY_COLLISION_TIER))
    testing.expect(t,  g4n.rect_collides_map(rect_2, tmap, tinfo, g4n.NORMAL_ENTITY_COLLISION_TIER))
    testing.expect(t, !g4n.rect_collides_map(rect_3, tmap, tinfo, g4n.NORMAL_ENTITY_COLLISION_TIER))
    testing.expect(t,  g4n.rect_collides_map(rect_4, tmap, tinfo, g4n.NORMAL_ENTITY_COLLISION_TIER))
    testing.expect(t,  g4n.rect_collides_map(rect_5, tmap, tinfo, g4n.NORMAL_ENTITY_COLLISION_TIER))
    testing.expect(t, !g4n.rect_collides_map(rect_6, tmap, tinfo, g4n.NORMAL_ENTITY_COLLISION_TIER))
}
@(test)
test_rect_movement_collision_map :: proc(t: ^testing.T) {
    tmap := g4n.load_map_from_file("tests/01.txt", 1)
    defer g4n.destroy_tilemap(&tmap)

    tinfo := g4n.create_tile_info()

    rect_1 := g4n.to_trect(g4n.FRect{0, 0, 1, 1})
    rect_2 := g4n.to_trect(g4n.FRect{0.5, 0.5, 1, 1})
    rect_3 := g4n.to_trect(g4n.FRect{1, 1, 1, 1})
    rect_4 := g4n.to_trect(g4n.FRect{3.5, 4, 8, 9})
    rect_5 := g4n.to_trect(g4n.FRect{5, 4, 3, 2})
    rect_6 := g4n.to_trect(g4n.FRect{1, 6, 1, 1})
 
    pos_1 := g4n.to_tvector(g4n.FVector{1, 1})
    pos_2 := g4n.to_tvector(g4n.FVector{1, 0})
    pos_3 := g4n.to_tvector(g4n.FVector{4, 6})
    pos_4 := g4n.to_tvector(g4n.FVector{3.5, 4})
    pos_5 := g4n.to_tvector(g4n.FVector{5, 3})
    pos_6 := g4n.to_tvector(g4n.FVector{5, 6})
    
    testing.expect(t,  g4n.tilemap_rect_movement_collision_occurs(rect_1, pos_1, tmap, tinfo, g4n.NORMAL_ENTITY_COLLISION_TIER))
    testing.expect(t,  g4n.tilemap_rect_movement_collision_occurs(rect_2, pos_2, tmap, tinfo, g4n.NORMAL_ENTITY_COLLISION_TIER))
    testing.expect(t, !g4n.tilemap_rect_movement_collision_occurs(rect_3, pos_3, tmap, tinfo, g4n.NORMAL_ENTITY_COLLISION_TIER))
    testing.expect(t, !g4n.tilemap_rect_movement_collision_occurs(rect_4, pos_4, tmap, tinfo, g4n.NORMAL_ENTITY_COLLISION_TIER))
    testing.expect(t,  g4n.tilemap_rect_movement_collision_occurs(rect_5, pos_5, tmap, tinfo, g4n.NORMAL_ENTITY_COLLISION_TIER))
    testing.expect(t, !g4n.tilemap_rect_movement_collision_occurs(rect_6, pos_6, tmap, tinfo, g4n.NORMAL_ENTITY_COLLISION_TIER))
}
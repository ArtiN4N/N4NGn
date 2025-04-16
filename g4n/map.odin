package g4n

import sdl "vendor:sdl3"
import img "vendor:sdl3/image"

import "core:math"
import "core:log"

Tile_Map :: struct {
    width_tiles: u32,
    height_tiles: u32,

    tile_size: u32,

    // inside array is y axis
    set: [dynamic][dynamic]Tile,
}

create_tile_map :: proc(
    info: Tile_Info, map_file: string = "", size : u32 = DEFAULT_TILE_SIZE
) -> (tmap: Tile_Map) {
    tmap.tile_size = size

    if len(map_file) == 0 {
        generate_random_map(&tmap, info)
    }

    /* load map file

    tmap.set = make([dynamic][dynamic]Tile, tmap.width_tiles, tmap.width_tiles)
    for i in 0..<tmap.width_tiles {
        tmap.set[i] = make([dynamic]Tile, tmap.height_tiles, tmap.height_tiles)
    }

    */
    log.logf(.Info, "Tile Map has been created.")
    return

}

destroy_tile_map :: proc(tmap: ^Tile_Map) {
    for i in 0..<tmap.width_tiles {
        delete(tmap.set[i])
    }
    delete(tmap.set)
    log.logf(.Info, "Tile Map has been destroyed.")
}

convert_position_to_map_index :: proc(vec: TVector, tile_size: u32) -> TVector {
    return vector_div_scalar(vec, tile_size)
}

get_map_indecies_bound_by_positions :: proc(a, b: TVector, tile_size: u32) -> (min_v, max_v: TVector) {
    a_bound := convert_position_to_map_index(a, tile_size)
    b_bound := convert_position_to_map_index(b, tile_size)

    min_v = TVector{ min(a_bound.x, b_bound.x), min(a_bound.y, b_bound.y) }
    max_v = TVector{ max(a_bound.x, b_bound.x), max(a_bound.y, b_bound.y) }

    return
}

get_map_index_rect :: proc(x, y: u32, tile_size: u32) -> TRect {
    rect_nw := TVector{x * tile_size, y * tile_size}
    rect_se := vector_add(rect_nw, TVector{tile_size - 1, tile_size - 1})
    return rect_from_nw_se(rect_nw, rect_se)
}

check_map_index_out_of_bounds :: proc(x, y: u32, tmap: Tile_Map) -> bool {
    return x < 0 || y < 0 || x >= tmap.width_tiles || y >= tmap.height_tiles
}

draw_tile_map :: proc(
    renderer: ^sdl.Renderer, tmap: Tile_Map, info: Tile_Info,
    t_sets: Texture_Set_Map, camera: Camera,
) {
    sdl.SetRenderDrawColor(renderer, 255, 255, 255, sdl.ALPHA_OPAQUE)

    dest := sdl.Rect{ 0, 0, cast(i32) tmap.tile_size, cast(i32) tmap.tile_size }

    for i in 0..<tmap.width_tiles {
        for j in 0..<tmap.height_tiles {

            dest.x = cast(i32) (i * tmap.tile_size)
            dest.y = cast(i32) (j * tmap.tile_size)

            text_key := info.texture_keys[tmap.set[i][j]]
            render_texture_via_camera(camera, renderer, get_tile_texture_with_key(t_sets, text_key), nil, &dest)
        }
    }
}

/*Tile_Map_check_entity_grounded :: proc(hitbox: Hitbox, tmap: Tile_Map, tinfo: Tile_Info, collision_tier: u8) -> bool {
    checking_line := Line{hitbox.corners[.SE], hitbox.corners[.SW]}

    checking_line.p1.y += 1
    checking_line.p2.y += 1

    return line_collides_map(checking_line, tmap, tinfo, collision_tier)
}*/

/*Tile_Map_check_entity_grab :: proc(hitbox: Hitbox, tmap: Tile_Map, tinfo: Tile_Info, collision_tier: u8, facing_right: bool) -> (should_grab: bool, tile: TilePoint) {
    should_grab = false
    tile = TilePoint{0, 0}

    top_corner := hitbox.corners[.NE]
    bottom_corner := hitbox.corners[.SE]

    if !facing_right {
        top_corner = hitbox.corners[.NW]
        bottom_corner = hitbox.corners[.SW]
    }

    top_tile := point_to_tile_position(top_corner, tmap)
    bottom_tile := point_to_tile_position(bottom_corner, tmap)

    top_tile_type := tmap.set[top_tile.x][top_tile.y]
    bottom_tile_type := tmap.set[bottom_tile.x][bottom_tile.y]

    adjacent_x := top_tile.x - 1
    if !facing_right { adjacent_x = top_tile.x + 1 }

    if tile_out_of_bounds(tmap, adjacent_x, 0) { adjacent_x = top_tile.x }

    top_adjacent_tile_type := tmap.set[adjacent_x][top_tile.y]

    if collision_tier < tinfo.collision_tier[bottom_tile_type] && tinfo.can_grab[bottom_tile_type] && collision_tier >= tinfo.collision_tier[top_tile_type] && collision_tier >= tinfo.collision_tier[top_adjacent_tile_type] {
        should_grab = true
        tile = bottom_tile
    }

    return
}*/
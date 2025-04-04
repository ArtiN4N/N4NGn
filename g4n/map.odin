package g4n

import sdl "vendor:sdl3"
import img "vendor:sdl3/image"
import "core:math"


TileMap :: struct {
    width_tiles: u32,
    height_tiles: u32,

    tile_size: u32,

    // inside array is y axis
    set: [dynamic][dynamic]Tile,

    player_spawn: TVector,
}

init_tilemap :: proc(tmap: ^TileMap, info: TileInfo, map_file: string = "", size : u32 = DEFAULT_TILE_SIZE) {
    tmap.tile_size = size

    if len(map_file) == 0 {
        generate_random_map(tmap, info)
        return
    }

    /* load map file

    tmap.set = make([dynamic][dynamic]Tile, tmap.width_tiles, tmap.width_tiles)
    for i in 0..<tmap.width_tiles {
        tmap.set[i] = make([dynamic]Tile, tmap.height_tiles, tmap.height_tiles)
    }

    */
}

destroy_tilemap :: proc(tmap: ^TileMap) {
    for i in 0..<tmap.width_tiles {
        delete(tmap.set[i])
    }
    delete(tmap.set)
}

convert_vector_by_map_dimensions :: proc(vec: FVector, tile_size: f32) -> FVector {
    return floor_fvector(vector_div_scalar(vec, tile_size))
}

/*tilemap_check_entity_grounded :: proc(hitbox: Hitbox, tmap: TileMap, tinfo: TileInfo, collision_tier: u8) -> bool {
    checking_line := Line{hitbox.corners[.SE], hitbox.corners[.SW]}

    checking_line.p1.y += 1
    checking_line.p2.y += 1

    return line_collides_map(checking_line, tmap, tinfo, collision_tier)
}*/

tile_out_of_bounds :: proc(tmap: TileMap, x, y: u32) -> bool {
    return x < 0 || y < 0 || x >= tmap.width_tiles || y >= tmap.height_tiles
}

/*tilemap_check_entity_grab :: proc(hitbox: Hitbox, tmap: TileMap, tinfo: TileInfo, collision_tier: u8, facing_right: bool) -> (should_grab: bool, tile: TilePoint) {
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

draw_tilemap :: proc(tmap: TileMap, info: TileInfo, camera: Camera, renderer: ^sdl.Renderer) {
    sdl.SetRenderDrawColor(renderer, 255, 255, 255, sdl.ALPHA_OPAQUE)

    dest := sdl.Rect{ 0, 0, cast(i32) tmap.tile_size, cast(i32) tmap.tile_size }

    for i in 0..<tmap.width_tiles {
        for j in 0..<tmap.height_tiles {

            dest.x = cast(i32) (i * tmap.tile_size)
            dest.y = cast(i32) (j * tmap.tile_size)
            render_texture_via_camera(camera, renderer, info.textures[tmap.set[i][j]], nil, &dest)
            //sdl.RenderTexture(renderer, info.textures[tmap.set[i][j]], nil, &dest)
        }
    }
}
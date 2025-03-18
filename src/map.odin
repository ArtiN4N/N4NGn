package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:unicode/utf8"
import "core:math/rand"
import "core:math"
import sdl "vendor:sdl3"
import img "vendor:sdl3/image"

DEFAULT_TILE_SIZE :: 80

Tile :: enum u8 { WALL = 0, BLANK, LEVEL_EXIT }

TileInfo :: struct {
    // if an entities collision tier is lower than the tile's, they collide with each other
    collision_tier: [Tile]u8,
    can_grab: [Tile]bool,
    textures: [Tile]^sdl.Texture,
}

init_tile_info :: proc(info: ^TileInfo, texture_sets: ^map[string]TextureSet) {
    path := "assets/tile/dat/properties.txt"

    data, ok := os.read_entire_file_from_filename(path)
    if !ok {
		log("Error! Could not read tile info properties file")
        return
	}
    defer delete(data)

    line_c: u8 = 0
    set : string = ""
    reading_data := false

    it := string(data)
	for line in strings.split_lines_iterator(&it) {
        if len(line) == 0 { continue }

        if line[0] == '$' {
            set = line[1:]
            continue
        }
        line_i := cast(Tile) line_c

        string_data := strings.split(line, ",")
        defer delete(string_data)

        info.collision_tier[line_i] = cast(u8) strconv.atoi(string_data[0])
        info.can_grab[line_i] = cast(bool) cast(int) strconv.atoi(string_data[1])
        info.textures[line_i] = texture_sets[set].textures[string_data[2]]

        line_c += 1
    }
}

TileMap :: struct {
    width_tiles: u32,
    height_tiles: u32,

    tile_size: u32,

    // inside array is y axis
    set: [dynamic][dynamic]Tile,

    player_spawn: TilePoint,
}

load_map_patterns :: proc(name: string) -> [2][16][16]Tile {
    ret : [2][16][16]Tile = {}

    slice := [?]string { "assets/map/dat/", name }
    file_path := strings.concatenate(slice[:])
    defer delete(file_path)

    data, ok := os.read_entire_file_from_filename(file_path)
    if !ok {
		log("Error! Could not read random map patterns file")
        return ret
	}
    defer delete(data)

    type := 0
    col := 0

    it := string(data)
	for line in strings.split_lines_iterator(&it) {
        if col == 16 {
            col = 0
            type += 1
            continue
        }

        for codepoint, row in line {
            tile_runes : [1]rune = {codepoint}
            str := utf8.runes_to_string(tile_runes[:])
            defer delete(str)
            tile := cast(Tile) strconv.atoi(str)
            ret[type][col][row] = tile
        }

        col += 1
    }

    return ret
}

generate_random_map :: proc(tmap: ^TileMap, info: TileInfo) {
    tmap.width_tiles = 64
    tmap.height_tiles = 32

    tmap.set = make([dynamic][dynamic]Tile, tmap.width_tiles, tmap.width_tiles)
    for i in 0..<tmap.width_tiles {
        tmap.set[i] = make([dynamic]Tile, tmap.height_tiles, tmap.height_tiles)

        for j in 0..<tmap.height_tiles {
            tmap.set[i][j] = .WALL
        }
    }

    patterns := load_map_patterns("basic_patterns.txt")

    possible_player_spawns := make([dynamic][2]u32)
    defer delete(possible_player_spawns)

    // to start, lets randomly generate map by 16x16 chunks
    for slice_x := 0; slice_x < 64; slice_x += 16 {
        for slice_y := 0; slice_y < 32; slice_y += 16 {
            pattern := rand.choice(patterns[:])

            for col := 0; col < 16; col += 1 {
                for row := 0; row < 16; row += 1 {
                    tmap.set[slice_x + col][slice_y + row] = pattern[col][row]

                    if slice_x == 0 && slice_y == 0 && pattern[col][row] == .BLANK && row < 15 {
                        if pattern[col][row + 1] == .WALL {
                            append(&possible_player_spawns, [2]u32{cast(u32)col, cast(u32)row})
                        }
                    }
                }
            }
        }
    }

    chosen_spawn := rand.choice(possible_player_spawns[:])

    tmap.player_spawn = chosen_spawn
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

pointi_to_tile_position :: proc(position: sdl.Point, tmap: TileMap) -> TilePoint {
    tile_pos := position

    tile_pos /= cast(i32) tmap.tile_size

    ret : TilePoint = { cast(u32) tile_pos.x, cast(u32) tile_pos.y }

    return ret
}

pointf_to_tile_position :: proc(position: sdl.FPoint, tmap: TileMap) -> TilePoint {
    tile_pos := position

    tile_pos /= cast(f32) tmap.tile_size

    ret : TilePoint = { cast(u32) math.floor_f32(tile_pos.x), cast(u32) math.floor_f32(tile_pos.y) }

    return ret
}

point_to_tile_position :: proc{ pointi_to_tile_position, pointf_to_tile_position }

line_collide_tile :: proc(line: Line, tile_pos: TilePoint, tile_size: u32) -> bool {

    x1 := cast(i32) (tile_pos.x * tile_size)
    y1 := cast(i32) (tile_pos.y * tile_size)
    x2 := x1 + cast(i32) tile_size
    y2 := y1 + cast(i32) tile_size

    // if a line is within the tile itself
    p1_inside := line.p1.x > x1 && line.p1.y > y1 && line.p1.x < x2 && line.p1.y < y2
    p2_inside := line.p2.x > x1 && line.p2.y > y1 && line.p2.x < x2 && line.p2.y < y2
    if p1_inside || p2_inside { return true }

    north_tline := Line{ { x1, y1 }, { x2, y1 } }
    east_tline := Line{ { x2, y1 }, { x2, y2 } }
    south_tline := Line{ { x2, y2 }, { x1, y2 } }
    west_tline := Line{ { x1, y2 }, { x1, y1 } }

    return line_collide_line(line, north_tline) || line_collide_line(line, east_tline) || line_collide_line(line, south_tline) || line_collide_line(line, west_tline)
}

get_tile_distance_from_point :: proc(point: sdl.Point, tile: TilePoint, tile_size: u32) -> f32 {
    point_2 := sdl.Point{ cast(i32) tile.x /*+ tile_size / 2*/, cast(i32) tile.y /*+ tile_size / 2*/ }
    return point_dist(point, point_2)
}

// line_to_nearest_collided_tile
// distance_to: Vector2f, 
line_collides_map :: proc( line: Line, tmap: TileMap, tinfo: TileInfo, line_collision_tier: u8) -> bool {
    discrete_pos1 := point_to_tile_position( line.p1, tmap )
    discrete_pos2 := point_to_tile_position( line.p2, tmap )

    max_discrete_x := max(discrete_pos1.x, discrete_pos2.x)
    min_discrete_x := min(discrete_pos1.x, discrete_pos2.x)

    max_discrete_y := max(discrete_pos1.y, discrete_pos2.y)
    min_discrete_y := min(discrete_pos1.y, discrete_pos2.y)

    //min_distance : f32 = math.F32_MAX
    //min_tile := Vector2u{}

    for i := min_discrete_x; i <= max_discrete_x; i += 1 {
        for j := min_discrete_y; j <= max_discrete_y; j += 1 {
            v := TilePoint{ i, j }
            if line_collide_tile(line, v, tmap.tile_size) && line_collision_tier < tinfo.collision_tier[tmap.set[i][j]]{
                return true
            } 
        }
    }

    return false
}

box_collides_map_ipoint :: proc(hitbox: Hitbox, position: sdl.Point, tmap: TileMap, tinfo: TileInfo, collision_tier: u8) -> bool {
    corners := hitbox_corners_with_iposition(hitbox, position)

    occupied := make([dynamic]TilePoint)
    defer delete(occupied)

    for vec in corners {
        u_vec := point_to_tile_position(vec, tmap)
        append(&occupied, u_vec)
    }

    for vec in occupied {
        if collision_tier < tinfo.collision_tier[tmap.set[vec.x][vec.y]] {
            return true
        }
    }

    return false
}

box_collides_map_fpoint :: proc(hitbox: Hitbox, position: sdl.FPoint, tmap: TileMap, tinfo: TileInfo, collision_tier: u8) -> bool {
    corners := hitbox_corners_with_fposition(hitbox, position)

    occupied := make([dynamic]TilePoint)
    defer delete(occupied)

    for vec in corners {
        u_vec := point_to_tile_position(vec, tmap)
        append(&occupied, u_vec)
    }

    for vec in occupied {
        if collision_tier < tinfo.collision_tier[tmap.set[vec.x][vec.y]] {
            return true
        }
    }

    return false
}

box_collides_map :: proc{ box_collides_map_ipoint, box_collides_map_fpoint }

tilemap_collision_correction_split_axis :: proc(
    hitbox: Hitbox, old_pos, new_pos: sdl.FPoint, velocity: sdl.FPoint, tmap: TileMap, tinfo: TileInfo, collision_tier: u8, dt: f32
) -> (corrected_pos: sdl.FPoint, collided_x, collided_y: bool) {
    corrected_pos = new_pos
    if new_pos == old_pos {
        collided_x = false
        collided_y = false
        return
    }
    

    new_corners := hitbox.corners
    old_corners := hitbox_corners_with_fposition(hitbox, old_pos)

    for corner in new_corners {
        if corner.x < 0 || corner.y < 0 { 
            corrected_pos = old_pos
            collided_x = false
            collided_y = false
            return
        }
    }

    nw_line := Line{ fpoint_to_point(old_corners[.NW]), new_corners[.NW] }
    ne_line := Line{ fpoint_to_point(old_corners[.NE]), new_corners[.NE] }
    se_line := Line{ fpoint_to_point(old_corners[.SE]), new_corners[.SE] }
    sw_line := Line{ fpoint_to_point(old_corners[.SW]), new_corners[.SW] }

    collision_occurs := line_collides_map(nw_line, tmap, tinfo, collision_tier)
    collision_occurs |= line_collides_map(ne_line, tmap, tinfo, collision_tier)
    collision_occurs |= line_collides_map(se_line, tmap, tinfo, collision_tier)
    collision_occurs |= line_collides_map(sw_line, tmap, tinfo, collision_tier)

    if !collision_occurs {
        collided_x = false
        collided_y = false
        return
    }

    move_diff_x := abs(old_pos.x - new_pos.x)
    move_diff_y := abs(old_pos.y - new_pos.y)

    subdivision_unit_x : f32 = math.floor_f32(cast(f32) tmap.tile_size / 2)
    subdivision_unit_y : f32 = math.floor_f32(cast(f32) tmap.tile_size / 2)

    subdivision_unit_x = math.min(move_diff_x / 2, subdivision_unit_x)
    subdivision_unit_y = math.min(move_diff_y / 2, subdivision_unit_y)

    if velocity.x < 0 { subdivision_unit_x *= -1 }
    if velocity.y < 0 { subdivision_unit_y *= -1 }

    min_subdiv_x := math.min(0.5, move_diff_x / 10)
    min_subdiv_y := math.min(0.5, move_diff_y / 10)

    corrected_pos = old_pos
    next_corrected_pos : sdl.FPoint = corrected_pos

    checking_x := move_diff_x > 0
    checking_y := move_diff_y > 0

    collided_x = false
    collided_y = false

    for checking_x || checking_y {
        n_vel := normalize_pointf(velocity)
        if checking_x {
            next_corrected_pos_x := corrected_pos.x + subdivision_unit_x
            check_corrected_pos := sdl.FPoint{ next_corrected_pos_x, corrected_pos.y }
            if box_collides_map(hitbox, check_corrected_pos, tmap, tinfo, collision_tier) {
                subdivision_unit_x /= 2
                collided_x = true
            } else {
                next_corrected_pos.x = next_corrected_pos_x
            }

            corrected_diff := abs(old_pos.x - next_corrected_pos.x)
            if abs(subdivision_unit_x) < abs(min_subdiv_x) || corrected_diff >= move_diff_x {
                checking_x = false
                if box_collides_map(hitbox, check_corrected_pos, tmap, tinfo, collision_tier) {
                    next_corrected_pos.x = corrected_pos.x
                }
            }
        }

        if checking_y {
            next_corrected_pos_y := corrected_pos.y + subdivision_unit_y
            check_corrected_pos := sdl.FPoint{ corrected_pos.x, next_corrected_pos_y }
            if box_collides_map(hitbox, check_corrected_pos, tmap, tinfo, collision_tier) {
                subdivision_unit_y /= 2
                collided_y = true
            } else {
                next_corrected_pos.y = next_corrected_pos_y
            }
            
            corrected_diff := abs(old_pos.y - next_corrected_pos.y)

            if abs(subdivision_unit_y) < abs(min_subdiv_y) || corrected_diff >= move_diff_y {
                checking_y = false
                if box_collides_map(hitbox, check_corrected_pos, tmap, tinfo, collision_tier) {
                    next_corrected_pos.y = corrected_pos.y
                }
            }
        }

        corrected_pos = next_corrected_pos
    }

    corrected_diff_x := abs(old_pos.x - corrected_pos.x)
    if corrected_diff_x > move_diff_x { corrected_pos.x = new_pos.x }
    
    corrected_diff_y := abs(old_pos.y - corrected_pos.y)
    if corrected_diff_y > move_diff_y {
        corrected_pos.y = new_pos.y
    }

    return
}

tilemap_check_entity_grounded :: proc(hitbox: Hitbox, tmap: TileMap, tinfo: TileInfo, collision_tier: u8) -> bool {
    checking_line := Line{hitbox.corners[.SE], hitbox.corners[.SW]}

    checking_line.p1.y += 1
    checking_line.p2.y += 1

    //fmt.printfln("ps = %v %v", checking_line.p1, checking_line.p2)

    return line_collides_map(checking_line, tmap, tinfo, collision_tier)
}

tile_out_of_bounds_coords :: proc(tmap: TileMap, x, y: u32) -> bool {
    return x < 0 || y < 0 || x >= tmap.width_tiles || y >= tmap.height_tiles
}

tile_out_of_bounds_vec :: proc(tmap: TileMap, pos: TilePoint) -> bool {
    return pos.x < 0 || pos.y < 0 || pos.x >= tmap.width_tiles || pos.y >= tmap.height_tiles
}

tile_out_of_bounds :: proc{ tile_out_of_bounds_coords, tile_out_of_bounds_vec }

tilemap_check_entity_grab :: proc(hitbox: Hitbox, tmap: TileMap, tinfo: TileInfo, collision_tier: u8, facing_right: bool) -> (should_grab: bool, tile: TilePoint) {
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
}

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
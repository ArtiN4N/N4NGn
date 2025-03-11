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

DEFAULT_TILE_SIZE :: 50

Tile :: enum u8 { WALL = 0, BLANK, LEVEL_EXIT }

TileInfo :: struct {
    // if an entities collision tier is lower than the tile's, they collide with each other
    collision_tier: [Tile]u8,
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
        info.textures[line_i] = texture_sets[set].textures[string_data[1]]

        line_c += 1
    }
}

TileMap :: struct {
    width_tiles: u32,
    height_tiles: u32,

    tile_size: u32,

    // inside array is y axis
    set: [dynamic][dynamic]Tile,

    player_spawn: Vector2u,
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

vector_to_tile_position :: proc(position: Vector2f, tmap: TileMap) -> Vector2u {
    tile_pos := position

    tile_pos /= cast(f32) tmap.tile_size

    ret : Vector2u = { cast(u32) math.floor_f32(tile_pos.x), cast(u32) math.floor_f32(tile_pos.y)  }

    return ret
}

line_collide_tile :: proc(line: linef, tile_pos: Vector2u, tile_size: u32) -> bool {

    x1 : f32 = cast(f32) tile_pos.x * cast(f32) tile_size
    y1 : f32 = cast(f32) tile_pos.y * cast(f32) tile_size
    x2 : f32 = x1 + cast(f32) tile_size
    y2 : f32 = y1 + cast(f32) tile_size

    north_tline := linef{ { x1, y1 }, { x2, y1 } }
    east_tline := linef{ { x2, y1 }, { x2, y2 } }
    south_tline := linef{ { x2, y2 }, { x1, y2 } }
    west_tline := linef{ { x1, y2 }, { x1, y1 } }

    return line_collide_line(line, north_tline) || line_collide_line(line, east_tline) || line_collide_line(line, south_tline) || line_collide_line(line, west_tline)
}

get_tile_distance_from_point :: proc(point: Vector2f, tile: Vector2u, tile_size: u32) -> f32 {
    point_2 := Vector2f{ cast(f32) tile.x + (cast(f32) tile_size) / 2.0, cast(f32) tile.y + (cast(f32) tile_size) / 2.0 }
    return vectorf_dist(point, point_2)
}

// line_to_nearest_collided_tile
// distance_to: Vector2f, 
line_collides_map :: proc( line: linef, tmap: TileMap, tinfo: TileInfo, line_collision_tier: u8) -> bool {
    discrete_pos1 := vector_to_tile_position( line.p1, tmap )
    discrete_pos2 := vector_to_tile_position( line.p2, tmap )

    max_discrete_x := max(discrete_pos1.x, discrete_pos2.x)
    min_discrete_x := min(discrete_pos1.x, discrete_pos2.x)

    max_discrete_y := max(discrete_pos1.y, discrete_pos2.y)
    min_discrete_y := min(discrete_pos1.y, discrete_pos2.y)

    //min_distance : f32 = math.F32_MAX
    //min_tile := Vector2u{}

    for i := min_discrete_x; i <= max_discrete_x; i += 1 {
        for j := min_discrete_y; j <= max_discrete_y; j += 1 {
            v := Vector2u{ i, j }
            if line_collide_tile(line, v, tmap.tile_size) && line_collision_tier < tinfo.collision_tier[tmap.set[i][j]]{
                return true
                //new_dist := get_tile_distance_from_point(distance_to, v, tmap.tile_size)
                //if new_dist < min_distance {
                    //min_distance = new_dist
                    //min_tile = v
                //}
            } 
        }
    }

    return false
}

box_collides_map :: proc(hitbox: Hitbox, position: Vector2f, tmap: TileMap, tinfo: TileInfo, collision_tier: u8) -> bool {
    corners := hitbox_corners_with_position(hitbox, position)

    occupied := make([dynamic]Vector2u)
    defer delete(occupied)

    for vec in corners {
        u_vec := vector_to_tile_position(vec, tmap)
        append(&occupied, u_vec)
    }

    for vec in occupied {
        if collision_tier < tinfo.collision_tier[tmap.set[vec.x][vec.y]] {
            return true
        }
    }

    return false
}

tilemap_collision_correction :: proc(hitbox: Hitbox, old_pos, new_pos, vel: Vector2f, tmap: TileMap, tinfo: TileInfo, collision_tier: u8) -> Vector2f {
    if new_pos == old_pos { return new_pos }
    corrected_pos := new_pos

    new_corners := hitbox.corners
    old_corners := hitbox_corners_with_position(hitbox, old_pos)

    for corner in new_corners {
        if corner.x < 0 || corner.y < 0 { 
            return old_pos 
        }
    }

    nw_line := linef{ old_corners[.NW], new_corners[.NW] }
    ne_line := linef{ old_corners[.NE], new_corners[.NE] }
    se_line := linef{ old_corners[.SE], new_corners[.SE] }
    sw_line := linef{ old_corners[.SW], new_corners[.SW] }

    collision_occurs := line_collides_map(nw_line, tmap, tinfo, collision_tier)
    collision_occurs |= line_collides_map(ne_line, tmap, tinfo, collision_tier)
    collision_occurs |= line_collides_map(se_line, tmap, tinfo, collision_tier)
    collision_occurs |= line_collides_map(sw_line, tmap, tinfo, collision_tier)

    if !collision_occurs {
        return new_pos
    }

    move_diff_x := abs(old_pos.x - new_pos.x)
    move_diff_y := abs(old_pos.y - new_pos.y)

    move_diff := math.sqrt(math.pow(move_diff_x, 2) + math.pow(move_diff_y, 2))

    subdivision_unit := math.floor_f32(cast(f32) tmap.tile_size / 2)

    subdivision_unit = math.min(move_diff / 2, subdivision_unit)

    corrected_pos = old_pos
    next_corrected_pos : Vector2f
    for subdivision_unit < 0.5 {
        next_corrected_pos = corrected_pos + normalize_vectorf(vel) * subdivision_unit
        if box_collides_map(hitbox, next_corrected_pos, tmap, tinfo, collision_tier) {
            subdivision_unit /= 2
            subdivision_unit = math.floor_f32(subdivision_unit)
        } else {
            corrected_pos = next_corrected_pos
        }
    }

    return corrected_pos
}

tilemap_collision_correction_split_axis :: proc(hitbox: Hitbox, old_pos, new_pos, vel: Vector2f, tmap: TileMap, tinfo: TileInfo, collision_tier: u8) -> Vector2f {
    if new_pos == old_pos { return new_pos }
    corrected_pos := new_pos

    new_corners := hitbox.corners
    old_corners := hitbox_corners_with_position(hitbox, old_pos)

    for corner in new_corners {
        if corner.x < 0 || corner.y < 0 { 
            return old_pos 
        }
    }

    nw_line := linef{ old_corners[.NW], new_corners[.NW] }
    ne_line := linef{ old_corners[.NE], new_corners[.NE] }
    se_line := linef{ old_corners[.SE], new_corners[.SE] }
    sw_line := linef{ old_corners[.SW], new_corners[.SW] }

    collision_occurs := line_collides_map(nw_line, tmap, tinfo, collision_tier)
    collision_occurs |= line_collides_map(ne_line, tmap, tinfo, collision_tier)
    collision_occurs |= line_collides_map(se_line, tmap, tinfo, collision_tier)
    collision_occurs |= line_collides_map(sw_line, tmap, tinfo, collision_tier)

    if !collision_occurs {
        return new_pos
    }

    move_diff_x := abs(old_pos.x - new_pos.x)
    move_diff_y := abs(old_pos.y - new_pos.y)

    subdivision_unit_x := math.floor_f32(cast(f32) tmap.tile_size / 2)
    subdivision_unit_y := math.floor_f32(cast(f32) tmap.tile_size / 2)

    subdivision_unit_x = math.min(move_diff_x / 2, subdivision_unit_x)
    subdivision_unit_y = math.min(move_diff_y / 2, subdivision_unit_y)

    corrected_pos = old_pos
    next_corrected_pos : Vector2f = corrected_pos

    checking_x := move_diff_x > 0
    checking_y := move_diff_y > 0

    for checking_x || checking_y {
        n_vel := normalize_vectorf(vel)
        if checking_x {
            next_corrected_pos_x := corrected_pos.x + n_vel.x * subdivision_unit_x
            check_corrected_pos := Vector2f{ next_corrected_pos_x, corrected_pos.y }
            if box_collides_map(hitbox, check_corrected_pos, tmap, tinfo, collision_tier) {
                subdivision_unit_x /= 2
                subdivision_unit_x = math.floor_f32(subdivision_unit_x)
            } else {
                next_corrected_pos.x = next_corrected_pos_x
            }

            corrected_diff := abs(old_pos.x - next_corrected_pos.x)
            if subdivision_unit_x < 0.5 || corrected_diff >= move_diff_x { checking_x = false }
        }

        if checking_y {
            next_corrected_pos_y := corrected_pos.y + n_vel.y * subdivision_unit_y
            check_corrected_pos := Vector2f{ corrected_pos.x, next_corrected_pos_y }
            if box_collides_map(hitbox, check_corrected_pos, tmap, tinfo, collision_tier) {
                subdivision_unit_y /= 2
                subdivision_unit_y = math.floor_f32(subdivision_unit_y)
            } else {
                next_corrected_pos.y = next_corrected_pos_y
            }

            corrected_diff := abs(old_pos.y - next_corrected_pos.y)
            if subdivision_unit_y < 0.5 || corrected_diff >= move_diff_y { checking_y = false }
        }

        corrected_pos = next_corrected_pos
    }

    corrected_diff_x := abs(old_pos.x - corrected_pos.x)
    if corrected_diff_x > move_diff_x { corrected_pos.x = new_pos.x }

    corrected_diff_y := abs(old_pos.y - corrected_pos.y)
    if corrected_diff_y > move_diff_y { corrected_pos.y = new_pos.y }

    return corrected_pos
}

draw_tilemap :: proc(tmap: TileMap, info: TileInfo, renderer: ^sdl.Renderer) {
    sdl.SetRenderDrawColor(renderer, 255, 255, 255, sdl.ALPHA_OPAQUE)

    dest := sdl.FRect{ 0, 0, cast(f32) tmap.tile_size, cast(f32) tmap.tile_size }

    for i in 0..<tmap.width_tiles {
        for j in 0..<tmap.height_tiles {
            dest.x = cast(f32) (i * tmap.tile_size)
            dest.y = cast(f32) (j * tmap.tile_size)
            sdl.RenderTexture(renderer, info.textures[tmap.set[i][j]], nil, &dest)
        }
    }
}
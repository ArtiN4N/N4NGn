package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"
import "core:unicode/utf8"
import "core:math/rand"
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
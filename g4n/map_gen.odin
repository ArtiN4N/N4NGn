package g4n

import "core:os"
import "core:strings"
import "core:strconv"
import "core:unicode/utf8"
import "core:math/rand"

init_map_set :: proc(tmap: ^TileMap) {
    tmap.set = make([dynamic][dynamic]Tile, tmap.width_tiles, tmap.width_tiles)
    for i in 0..<tmap.width_tiles {
        tmap.set[i] = make([dynamic]Tile, tmap.height_tiles, tmap.height_tiles)

        for j in 0..<tmap.height_tiles {
            tmap.set[i][j] = .WALL
        }
    }
}

load_map_from_file :: proc(fname: string, tile_size: u32) -> (loaded: TileMap) {
    loaded.tile_size = tile_size

    slice := [?]string { "assets/map/dat/", fname }
    file_path := strings.concatenate(slice[:])
    defer delete(file_path)

    data, ok := os.read_entire_file_from_filename(file_path)
    if !ok {
		log("Error! Could not load map from file")
        return
	}
    defer delete(data)

    

    row := 0
    it := string(data)
	for line in strings.split_lines_iterator(&it) {
        if line[0] == '$' {
            string_data := strings.split(line[1:], "&")
            defer delete(string_data)

            loaded.width_tiles = u32(strconv.atoi(string_data[0]))
            loaded.height_tiles = u32(strconv.atoi(string_data[1]))

            init_map_set(&loaded)
            continue
        }

        for codepoint, col in line {
            tile_runes : [1]rune = {codepoint}
            str := utf8.runes_to_string(tile_runes[:])
            defer delete(str)
            tile := cast(Tile) strconv.atoi(str)
            loaded.set[col][row] = tile
        }

        row += 1
    }

    return
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
    row := 0

    it := string(data)
	for line in strings.split_lines_iterator(&it) {
        if row == 16 {
            row = 0
            type += 1
            continue
        }

        for codepoint, col in line {
            tile_runes : [1]rune = {codepoint}
            str := utf8.runes_to_string(tile_runes[:])
            defer delete(str)
            tile := cast(Tile) strconv.atoi(str)
            ret[type][col][row] = tile
        }

        row += 1
    }

    return ret
}

generate_random_map :: proc(tmap: ^TileMap, info: TileInfo) {
    tmap.width_tiles = 64
    tmap.height_tiles = 32

    init_map_set(tmap)

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
                            append(&possible_player_spawns, [2]u32{u32(col), u32(row)})
                        }
                    }
                }
            }
        }
    }

    chosen_spawn := rand.choice(possible_player_spawns[:])

    //tmap.player_spawn = chosen_spawn
}
package g4n

import "core:log"
import "core:os"
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:unicode/utf8"
import "core:math/rand"

MAP_DATA_DESINATION :: "data/map/"

init_map_set :: proc(tmap: ^Tile_Map) {
    tmap.set = make([dynamic][dynamic]Tile, tmap.width_tiles, tmap.width_tiles)
    for i in 0..<tmap.width_tiles {
        tmap.set[i] = make([dynamic]Tile, tmap.height_tiles, tmap.height_tiles)

        for j in 0..<tmap.height_tiles {
            tmap.set[i][j] = .WALL
        }
    }

    log.logf(.Debug, "Tile Map set data has been created.")
}

load_map_from_file :: proc(fname: string, tile_size: u32) -> (loaded: Tile_Map) {
    loaded.tile_size = tile_size

    slice := [?]string { MAP_DATA_DESINATION, fname }
    file_path := strings.concatenate(slice[:])

    data: []byte
    ok: bool

    if data, ok = os.read_entire_file_from_filename(file_path); !ok {
        log.logf(.Fatal, "Could not read map data from path %v!", file_path)
        delete(file_path)
		panic("FATAL crash! See log file for info.")
	}
    delete(file_path)
    defer delete(data)

    

    row := 0
    it := string(data)
    // See map_data_parse.md for an explanation of the formatting
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

    log.logf(.Info, "Map loaded from file %v.", file_path)
    return
}

load_map_patterns :: proc(name: string) -> [2][16][16]Tile {
    ret : [2][16][16]Tile = {}

    slice := [?]string { MAP_DATA_DESINATION, name }
    file_path := strings.concatenate(slice[:])

    data: []byte
    ok: bool

    if data, ok = os.read_entire_file_from_filename(file_path); !ok {
        log.logf(.Fatal, "Could not read map patterns data from path %v!", file_path)
        delete(file_path)
		panic("FATAL crash! See log file for info.")
	}
    delete(file_path)
    defer delete(data)

    type := 0
    row := 0

    it := string(data)
    // See map_patterns_parse.md for an explanation of the formatting
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

    log.logf(.Info, "Map patterns loaded from file %v.", file_path)
    return ret
}

generate_random_map :: proc(tmap: ^Tile_Map, info: Tile_Info) {
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
    log.logf(.Info, "Finished random map generation.")
}
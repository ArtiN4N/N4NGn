package g4n

import sdl "vendor:sdl3"
import img "vendor:sdl3/image"
import "core:os"
import "core:strings"
import "core:strconv"

DEFAULT_TILE_SIZE :: 80

NORMAL_ENTITY_COLLISION_TIER :: 0

Tile :: enum u8 { WALL = 0, BLANK, LEVEL_EXIT }

TileInfo :: struct {
    // if an entities collision tier is lower than the tile's, they collide with each other
    collision_tier: [Tile]u8,
    can_grab: [Tile]bool,
    textures: [Tile]^sdl.Texture,
}

create_tile_info :: proc(texture_sets: ^map[string]TextureSet = nil) -> (info: TileInfo) {
    path := "data/tile_properties.txt"

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
        if texture_sets != nil { info.textures[line_i] = texture_sets[set].textures[string_data[2]] }

        line_c += 1
    }

    return
}
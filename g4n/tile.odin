package g4n

import sdl "vendor:sdl3"
import img "vendor:sdl3/image"

import "core:os"
import "core:log"
import "core:strings"
import "core:strconv"

DEFAULT_TILE_SIZE :: 50
NORMAL_ENTITY_COLLISION_TIER :: 0

Tile :: enum u8 { WALL = 0, BLANK, LEVEL_EXIT }

Tile_Info :: struct {
    // if an entities collision tier is lower than the tile's, they collide with each other
    collision_tier: [Tile]u8,
    can_grab: [Tile]bool,
    texture_keys: [Tile]Texture_Key,
}

@(require_results)
resolve_tile_texture :: proc(
    tile: Tile, tile_text_info: Texture_Key, texture_sets: ^Texture_Set_Map
) -> (
    texture: ^sdl.Texture, ok: bool
) {
    // Fatal crash if the desired texture set doesn't exist. This is bad and indicates an error in the actual tile data,
    // or even worse, the game isnt initializing the texture sets map.
    if !(tile_text_info.texture_set_name in texture_sets) {
        log.logf(
            .Fatal,
            "Either the state's texture set map is uninitialized, or tile %v thinks its texture is in the nonexistant texture set %s.",
            typeid_of(Tile), tile_text_info.texture_set_name
        )
        panic("FATAL crash! See log file for info.")
    }
    //---------------------------------------------------------------------------------------------------------------------------------

    // An error which occurs when a tile wants it's texture resolved, but the belonging
    if !texture_sets[tile_text_info.texture_set_name].loaded {
        log.logf(
            .Error,
            "Tile %v wants to be drawn to screen, but its texture belongs to set %s which is unloaded.",
            typeid_of(Tile), tile_text_info.texture_set_name
        )
        return nil, false
    }
    //--------------------------------------------------------------------------------------------------

    ok = true
    texture = texture_sets[tile_text_info.texture_set_name].textures[tile_text_info.path]

    return
}

TILE_INFO_DESTINATION :: "data/tile_properties.txt"

@(require_results)
create_tile_info :: proc() -> (info: Tile_Info) {
    path := TILE_INFO_DESTINATION
    
    data: []byte
    ok: bool

    if data, ok = os.read_entire_file_from_filename(path); !ok {
		log.logf(.Fatal, "Could not read tile properties from path %v!", path)
		panic("FATAL crash! See log file for info.")
	}
    defer delete(data)

    line_c: u8 = 0
    set: string = ""
    reading_data := false


    // See tile_info_parse.md for an explanation of the formatting for tile properties
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

        info.collision_tier[line_i] = u8(strconv.atoi(string_data[0]))
        info.can_grab[line_i] = cast(bool) int(strconv.atoi(string_data[1]))
        // We clone the string because the string data is from a file handle, and is soon to be deleted
        info.texture_keys[line_i] = Texture_Key{strings.clone(set), strings.clone(string_data[2])}

        line_c += 1
    }
    log.logf(.Info, "Created tile info.")
    return
}

destroy_tile_info :: proc(info: ^Tile_Info) {
    for &key in info.texture_keys {
        log.logf(.Debug, "Tile info has destroyed path string data %v", key.path)
        log.logf(.Debug, "Tile info has destroyed texture set name string data %v", key.texture_set_name)
        delete(key.path)
        delete(key.texture_set_name)
    }
}
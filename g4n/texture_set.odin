package g4n

import sdl "vendor:sdl3"
import img "vendor:sdl3/image"

import "core:os"
import "core:log"
import "core:fmt"
import "core:strings"
import "core:strconv"

TEXTURE_SETS_DATA_DESTINATION :: "data/texture_sets.txt"

// Allows for dynamic loading and unloading of a group of texture simeulteanously
// Textures can only belong to 0 or 1 texture sets
// Texture sets are static, and decided at compile time
// Path acts as a parent path: if texture set a has path go/to/here,
// and owns a texture for/this.png, then upon loading, it will look for the path
// (relative to the executable) go/to/here/for/this.png
Texture_Set :: struct {
    textures: map[string]^sdl.Texture,
    files: [dynamic]string,
    path: string,
    loaded: bool,
}
Texture_Set_Map :: map[string]Texture_Set

Texture_Key :: struct {
    texture_set_name: string,
    path: string,
}

@(require_results)
get_tile_texture_with_key :: proc(tsets: Texture_Set_Map, key: Texture_Key) -> ^sdl.Texture {
    if !(key.texture_set_name in tsets) {
        log.logf(.Fatal, "Tried to access texture from nonexistent texture set %v. Valid texture sets: %v", key.texture_set_name, tsets)
		panic("FATAL crash! See log file for info.")
    }

    if !(key.path in tsets[key.texture_set_name].textures) {
        log.logf(.Fatal, "Tried to access nonexistent texture %v from texture set %v. Valid textures: %v", key.path, key.texture_set_name, tsets[key.texture_set_name].textures)
		panic("FATAL crash! See log file for info.")
    }

    return tsets[key.texture_set_name].textures[key.path]
}

// This procedure should only be run by the init_texture_sets procedure
create_texture_set :: proc(path: string, name: string, files: ..string) -> Texture_Set {
    tSet : Texture_Set

    tSet.textures = make(map[string]^sdl.Texture)
    log.logf(.Debug, "Created a texture_set %s's textures data.", name)

    tSet.files = make([dynamic]string)
    log.logf(.Debug, "Created a texture_set %s's files data.", name)
    for file in files {
        // We clone the string because the passed files list is from a file handle,
        // and is free'd shortly after the invocation of this procedure.
        append(&tSet.files, strings.clone(file))
        log.logf(.Debug, "Added file with string data %v to set %s.", file, name)
    }

    // Similar cloning reason for the path.
    tSet.path = strings.clone(path)
    log.logf(.Debug, "Created string data %v for the set %s's path.", path, name)

    tSet.loaded = false

    log.logf(.Info, "Texture set %s created and set to unloaded.", name)
    return tSet
}

// Loads the actual texture set's textures data into memory
load_texture_set :: proc(set: ^Texture_Set, renderer: ^sdl.Renderer, name: string) {
    for file in set.files {
        // Combine set path and file destination for the actual path
        slice := [?]string { set.path, file }
        file_path := strings.concatenate(slice[:])
        defer delete(file_path)
        //----------------------------------------

        cstr_path := strings.clone_to_cstring(file_path)
        set.textures[file] = img.LoadTexture(renderer, cstr_path)
        delete(cstr_path)

        if set.textures[file] == nil {
            log.logf(
                .Error,
                "Texture set %s tried to load texture %s from realpath %s but failed. Corresponding SDL error: %s",
                name, file, file_path, sdl.GetError()
            )
        } else {
            sdl.SetTextureScaleMode(set.textures[file], sdl.ScaleMode.NEAREST)
            log.logf(
                .Info,
                "Texture set %s has loaded texture %s from realpath %s.",
                name, file, file_path
            )
        }
    }

    set.loaded = true
    log.logf(.Info, "Texture set %s is now loaded.", name)
}

unload_texture_set :: proc(set: ^Texture_Set, name: string) {
    for key, &value in set.textures {
        sdl.DestroyTexture(value)
        log.logf(.Info, "Texture set %s has destroyed texture %s.", name, key)
    }

    clear(&set.textures)

    set.loaded = false
    log.logf(.Info, "Texture set %s is now unloaded.", name)
}

destroy_texture_set :: proc(set: ^Texture_Set, name: string) {
    if set.loaded { unload_texture_set(set, name) }

    delete(set.textures)
    log.logf(.Debug, "Texture set %s has destroyed textures data.", name)

    for file in &set.files {
        log.logf(.Debug, "Texture set %s has destroyed file string data %s.", name, file)
        delete(file)
    }
    delete(set.files)
    log.logf(.Debug, "Texture set %s has destroyed files data.", name)

    log.logf(.Debug, "Texture set %s has destroyed path string data %s.", name, set.path)
    delete(set.path)

    log.logf(.Info, "Texture set %s has been destroyed.", name)
}

init_texture_sets :: proc(t_sets: ^Texture_Set_Map) {
    data: []byte
    ok: bool

    if data, ok = os.read_entire_file_from_filename(TEXTURE_SETS_DATA_DESTINATION); !ok {
		log.logf(.Fatal, "Could not read texture set data from path %v!", TEXTURE_SETS_DATA_DESTINATION)
		panic("FATAL crash! See log file for info.")
	}
    defer delete(data)

    name := ""
    file_count := 0
    files_read := 0
    file_path := ""
    reading_path := false
    files : [dynamic]string = make([dynamic]string)
    defer delete(files)

    // See texture_set_parse.md for an explanation of the formatting for tile properties
    // Data for a texture set starts with the $ character.
    // On that same line is the name of the texture set, followed by an & character, and then the number of files in the set n.
    // The next n lines are the names of the files in the set.
    it := string(data)
	for line in strings.split_lines_iterator(&it) {
        if len(line) == 0 { continue }

        if line[0] == '$' {
            string_data := strings.split(line[1:], "&")
            defer delete(string_data)

            name = string_data[0]
            file_count = strconv.atoi( string_data[1] )
            reading_path = true

            continue
        }

        if reading_path {
            file_path = line
            reading_path = false
            continue
        }

        if files_read < file_count {
            append(&files, line)
            files_read += 1
        }
        if files_read == file_count {
            t_sets[strings.clone(name)] = create_texture_set(file_path, name, ..files[:])
            log.logf(.Debug, "Texture set %s has created set name string data.", name)

            name = ""
            file_count = 0
            files_read = 0
            file_path = ""
            clear(&files)
        }
	}

    log.logf(.Info, "Texture sets have been initialized.")
}
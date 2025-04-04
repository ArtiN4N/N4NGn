package g4n

import sdl "vendor:sdl3"
import img "vendor:sdl3/image"
import "core:os"
import "core:strings"
import "core:strconv"

// Allows for dynamic loading and unloading of a group of texture simeulteanously
TextureSet :: struct {
    textures: map[string]^sdl.Texture,
    files: [dynamic]string,
    path: string,
}

// Just call this proc with a path and whatever files are to be added to the texture set.
create_texture_set :: proc(path: string, files: ..string) -> TextureSet {
    tSet : TextureSet

    tSet.textures = make(map[string]^sdl.Texture)

    tSet.files = make([dynamic]string)
    for file in files {
        log("adding file %v to set", file)
        append(&tSet.files, strings.clone(file))
    }

    tSet.path = strings.clone(path)

    return tSet
}

load_texture_set :: proc(set: ^TextureSet, renderer: ^^sdl.Renderer, name: string) {
    log("Loading texture set %v", name)
    for file in set.files {
        slice := [?]string { set.path, file }
        file_path := strings.concatenate(slice[:])
        defer delete(file_path)

        cstr_path := strings.clone_to_cstring(file_path)
        set.textures[file] = img.LoadTexture(renderer^, cstr_path)
        delete(cstr_path)

        if set.textures[file] == nil {
            log("Error loading texture from file %s: %s", file_path, sdl.GetError())
        }

        sdl.SetTextureScaleMode(set.textures[file], sdl.ScaleMode.NEAREST)
        log("Loaded texture from file %v.", file_path)

        
    } 
}

destroy_texture_set :: proc(set: ^TextureSet, name: string) {
    for key, &value in set.textures {
        sdl.DestroyTexture(value)
        log("Destroyed %v texture.", key)
    }

    delete(set.textures)

    for file in &set.files {
        delete(file)
    }
    delete(set.files)
    delete(set.path)

    log("Destroyed texture set %v", name)
}

// Texture sets are init from a master file.
// Data for a texture set starts with the $ character.
// On that same line is the name of the texture set, followed by an & character, and then the number of files in the set n.
// The next n lines are the names of the files in the set.
init_texture_sets :: proc(t_sets: ^map[string]TextureSet) {
    data, ok := os.read_entire_file_from_filename("assets/texture_set/sets.txt")
    if !ok {
		log("Error! Could not read texture set loading file")
        return
	}
    defer delete(data)

    name := ""
    file_count := 0
    files_read := 0
    file_path := ""
    reading_path := false
    files : [dynamic]string = make([dynamic]string)
    defer delete(files)

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
            t_sets[strings.clone(name)] = create_texture_set(file_path, ..files[:])

            name = ""
            file_count = 0
            files_read = 0
            file_path = ""
            clear(&files)
        }
	}
}
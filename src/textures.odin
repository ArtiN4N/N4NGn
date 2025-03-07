package main

import "core:fmt"
import "core:os"
import "core:strings"
import sdl "vendor:sdl3"
import img "vendor:sdl3/image"

TextureSet :: struct {
    textures: map[string]^sdl.Texture,
    files: [dynamic]string,
    path: string,
}

create_texture_set :: proc(path: string, files: ..string) -> TextureSet {
    tSet : TextureSet

    tSet.textures = make(map[string]^sdl.Texture)

    tSet.files = make([dynamic]string)
    append(&tSet.files, ..files)

    tSet.path = path

    return tSet
}

load_texture_set :: proc(set: ^TextureSet, renderer: ^^sdl.Renderer, name: string) {
    log("Loading texture set %v", name)
    for file in set.files {
        slice := [?]string { set.path, file }
        file_path := strings.concatenate(slice[:])

        set.textures[file] = img.LoadTexture(renderer^, strings.clone_to_cstring(file_path))
        if set.textures[file] == nil {
            log("Error loading texture from file %s: %s", file_path, sdl.GetError())
        }

        log("Loaded texture from file %v.", file_path)
    }

    delete(set.files)
}

destroy_texture_set :: proc(set: ^TextureSet, name: string) {
    for key, &value in set.textures {
        sdl.DestroyTexture(value)
        log("Destroyed %v texture.", key)
    }

    delete(set.textures)
    log("Destroyed texture set %v", name)
}
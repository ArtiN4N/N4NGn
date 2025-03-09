package main

import "core:fmt"
import "core:os"
import "core:strings"
import sdl "vendor:sdl3"
import img "vendor:sdl3/image"

Camera :: struct {
    source: sdl.FRect,
    dest: sdl.FRect,

    cam_texture: ^sdl.Texture,
    renderer: ^sdl.Renderer,

    anchor: ^Vector2f
}

init_camera :: proc(camera: ^Camera, renderer: ^sdl.Renderer, width, height: f32, anchor: ^Vector2f) {
    camera.renderer = renderer

    camera.source = { 0, 0, width, height }
    camera.dest = { 0, 0, width, height }

    camera.cam_texture = sdl.CreateTexture(renderer, sdl.PixelFormat.RGBA8888, sdl.TextureAccess.TARGET, 3200, 3200)

    camera.anchor = anchor
}

destroy_camera :: proc(camera: ^Camera) {
    sdl.DestroyTexture(camera.cam_texture)
}

start_camera_render :: proc(camera: ^Camera) {
    sdl.SetRenderTarget(camera.renderer, camera.cam_texture)
    sdl.SetRenderDrawColor(camera.renderer, 0, 0, 0, 0)
    sdl.RenderClear(camera.renderer)
}

end_camera_render :: proc(camera: ^Camera) {

    source := camera.source

    anchor := camera.anchor^

    round_decimals(&anchor.x, &anchor.y)

    source.x = anchor.x - source.w / 2
    source.y = anchor.y - source.h / 2

    if source.x < 0 { source.x = 0 }
    if source.x > cast(f32) camera.cam_texture.w - source.w { source.x = cast(f32) camera.cam_texture.w -source.w }
    if source.y < 0 { source.y = 0 }
    if source.y > cast(f32) camera.cam_texture.h - source.h { source.y = cast(f32) camera.cam_texture.h - source.h }

    sdl.SetRenderTarget(camera.renderer, nil)
    sdl.RenderTexture(camera.renderer, camera.cam_texture, &source, &camera.dest)
}
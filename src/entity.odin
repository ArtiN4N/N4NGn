package main

import "core:fmt"
import "core:os"
import "core:strings"
import sdl "vendor:sdl3"
import img "vendor:sdl3/image"

// Basic entity struct. Can be wrapped around for a more advanced type of entity.
Entity :: struct {
    texture: ^^sdl.Texture,
    // Texture src refers to a rectangle within the actual image file
    // It will use the rect to basically grab whatever pixels are needed from the image
    // Useful for spritesheets
    texture_src_position: sdl.Point,
    texture_src_size: sdl.Point,

    // Texture dest is where on the screen the texture is to be drawn to
    // Texture offset is used in place of position
    // We assume that the texture is to be drawn anchored to the entity,
    // and so offset just describes how to move
    texture_dest_offset: sdl.Point,
    texture_dest_size: sdl.Point,

    // position is in the centre of hitbox
    position: sdl.FPoint,
    velocity: sdl.FPoint,
    acceleration: sdl.FPoint,

    // movement vectors should be seperated from total vectors
    // allows for entitys to be moving one way, while some force is pushing them the other way
    move_velocity: sdl.FPoint,
    global_velocity: sdl.FPoint,
    move_acceleration: sdl.FPoint,

    discrete_position: sdl.Point,

    // generally used for combat or spawning purposes
    // aka an entity facing right should never shoot bullets to its left (unless its supposed to)
    facing_right: bool,
    grounded: bool,
    grabbing: bool,
    grabbing_target_tile: TilePoint,
    grounded_timer: f32,
    is_walking: bool,

    walk_speed: f32,
    run_speed: f32,

    jump_vel : f32,

    combat_hitbox: Hitbox,
    collision_hitbox: Hitbox,
    grab_hitbox: Hitbox,

    // if an entities collision tier is lower than a tile's, they collide with each other
    collision_tier: u8,
}
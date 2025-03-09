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
    texture_src_position: Vector2f,
    texture_src_size: Vector2f,

    // Texture dest is where on the screen the texture is to be drawn to
    // Texture offset is used in place of position
    // We assume that the texture is to be drawn anchored to the entity,
    // and so offset just describes how to move
    texture_dest_offset: Vector2f,
    texture_dest_size: Vector2f,

    // position is in the centre of hitbox
    position: Vector2f,
    velocity: Vector2f,
    acceleration: Vector2f,

    // movement vectors should be seperated from total vectors
    // allows for entitys to be moving one way, while some force is pushing them the other way
    move_velocity: Vector2f,
    move_acceleration: Vector2f,

    // generally used for combat or spawning purposes
    // aka an entity facing right should never shoot bullets to its left (unless its supposed to)
    facing_right: bool,

    is_walking: bool,

    walk_speed: f32,
    run_speed: f32,

    // jump speed can be determined using how high the entity jumps, and for how long it should be in the air
    jump_height: f32,
    jump_duration: f32,

    combat_hitbox: Hitbox,
    collision_hitbox: Hitbox,

    // if an entities collision tier is lower than a tile's, they collide with each other
    collision_tier: u8,
}
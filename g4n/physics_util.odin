package g4n
import sdl "vendor:sdl3"

ForceHandle :: ^Force

DECAY_MINIMUM :: 0.05

// For velocity and acceleration
Force :: struct {
    direction: FVector,
    //magnitude: f32,
    decay: f32,
}

apply_force :: proc(f: ^Force) -> (r: FVector) {
    r = f.direction
    f.direction = vector_mult_scalar(f.direction, f.decay)
    if abs(f.direction.x) < DECAY_MINIMUM { f.direction.x = 0 }
    if abs(f.direction.y) < DECAY_MINIMUM { f.direction.y = 0 }
    return
}

read_force :: proc(f: Force) -> (r: FVector) {
    r = f.direction
    return
}

PhysicsBody :: struct {
    // the position of this rect acts as an offset from the anchor
    rect: FRect,
    anchor: ^FVector
}

make_physics_body :: proc(anchor: ^FVector, x, y, w, h : f32) -> (body: PhysicsBody) {
    body.rect = FRect{x, y, w, h}
    body.anchor = anchor
    return
}

get_real_physics_body_rect :: proc(body: PhysicsBody) -> FRect {
    return rect_add_vector(body.rect, body.anchor^)
}
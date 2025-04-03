package g4n
import sdl "vendor:sdl3"

// For velocity and acceleration
Force :: struct {
    direction: FVector,
    magnitude: f32,
    decay: f32,
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
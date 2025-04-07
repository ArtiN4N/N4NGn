package g4n
import sdl "vendor:sdl3"

ForceHandle :: ^Force

DecayPct :: f32

DECAY_MINIMUM :: 0.05

get_decay_factor :: proc(pct: DecayPct) -> f32 {
    if pct == 0 { return 1 }
    if pct < 0 { return 0 }
    return 1 - (1 / pct)
}

// For velocity and acceleration
Force :: struct {
    direction: FVector,
    //magnitude: f32,

    
    decay: DecayPct,
}

CompoundForce :: struct {
    compound: FVector,
    direction: FVector,
    //magnitude: f32,

    comp_decay: DecayPct,
    dir_decay: DecayPct,
}

apply_compound_force :: proc(f: ^CompoundForce, dt: f32) -> (r: FVector) {
    f.direction = vector_add(f.direction, vector_mult_scalar(f.compound, dt)) 
    r = f.direction

    f.direction = vector_mult_scalar(f.direction, get_decay_factor(f.dir_decay / dt))
    f.compound = vector_mult_scalar(f.compound, get_decay_factor(f.comp_decay / dt))

    if abs(f.direction.x) < DECAY_MINIMUM { f.direction.x = 0 }
    if abs(f.direction.y) < DECAY_MINIMUM { f.direction.y = 0 }

    if abs(f.compound.x) < DECAY_MINIMUM { f.compound.x = 0 }
    if abs(f.compound.y) < DECAY_MINIMUM { f.compound.y = 0 }

    return
}

read_compound_force :: proc(f: CompoundForce) -> (r: FVector) {
    r = f.direction
    return
}

apply_force :: proc(f: ^Force, dt: f32) -> (r: FVector) {
    r = f.direction
    f.direction = vector_mult_scalar(f.direction, get_decay_factor(f.decay / dt))
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
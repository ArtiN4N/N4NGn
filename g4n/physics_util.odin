package g4n

import sdl "vendor:sdl3"

import "core:math"
import "core:log"

//needs fixing
ForceHandle :: ^Force

DECAY_MINIMUM :: 0.05
DECAY_PCT_MAXIMUM :: 100

Force_Decay :: struct {
    pct: f32,
    per_second: bool,
}

// This is a procedure that, given a force decay, which records the rate of decay as a %
// Because this procedure will run every frame, as in, the force will be multiplied by the decay factor every frame,
// if we want to decay by a % per second, we have to inverse this.
// Thus we can raise the decay factor to the dt-th power.
get_decay_factor :: proc(decay: Force_Decay, dt: f32) -> (r: f32) {
    if decay.pct <= 0 || dt == 0 { return 1 }
    if decay.pct >= DECAY_PCT_MAXIMUM { return 0 }

    r = 1 - (decay.pct / DECAY_PCT_MAXIMUM)

    if decay.per_second { r = math.pow(r, dt) }

    return
}

Force :: struct {
    direction: FVector,
    decay: Force_Decay,
}

create_force :: proc(
    direction: FVector, direction_decay: f32, decay_is_per_second: bool
) -> (f: Force) {
    f.direction = direction
    f.decay = Force_Decay{direction_decay, decay_is_per_second}

    log.logf(.Debug, "Created Force.")
    return
}

apply_force :: proc(f: ^Force, dt: f32) -> (r: FVector) {
    r = f.direction

    f.direction = vector_mult_scalar(f.direction, get_decay_factor(f.decay, dt))

    if abs(f.direction.x) < DECAY_MINIMUM { f.direction.x = 0 }
    if abs(f.direction.y) < DECAY_MINIMUM { f.direction.y = 0 }
    return
}

Compound_Force :: struct {
    compound: FVector,
    direction: FVector,

    comp_decay: Force_Decay,
    dir_decay: Force_Decay,
}

create_compound_force :: proc(
    compound: FVector, compound_decay, direction_decay: f32, decay_is_per_second: bool
) -> (cf: Compound_Force) {
    cf.compound = compound
    cf.direction = FVECTOR_ZERO
    cf.comp_decay = Force_Decay{compound_decay, decay_is_per_second}
    cf.dir_decay = Force_Decay{direction_decay, decay_is_per_second}

    log.logf(.Debug, "Created Compound Force.")
    return
}

apply_compound_force :: proc(f: ^Compound_Force, dt: f32) -> (r: FVector) {
    // A compound force's compound vector is the per-time-unit change in velocity
    // Its direction vector is the resultant velocity from the "unit" of acceleration
    f.direction += vector_mult_scalar(f.compound, dt)
    r = f.direction

    f.direction = vector_mult_scalar(f.direction, get_decay_factor(f.dir_decay, dt))
    f.compound = vector_mult_scalar(f.compound, get_decay_factor(f.comp_decay, dt))

    if abs(f.direction.x) < DECAY_MINIMUM { f.direction.x = 0 }
    if abs(f.direction.y) < DECAY_MINIMUM { f.direction.y = 0 }

    if abs(f.compound.x) < DECAY_MINIMUM { f.compound.x = 0 }
    if abs(f.compound.y) < DECAY_MINIMUM { f.compound.y = 0 }

    return
}


Physics_Body :: struct {
    // the position of this rect acts as an offset from the anchor
    rect: FRect,
    anchor: ^FVector
}

make_physics_body :: proc(anchor: ^FVector, x, y, w, h : f32) -> (body: Physics_Body) {
    body.rect = FRect{x, y, w, h}
    body.anchor = anchor

    log.logf(.Debug, "Created Physics Body.")
    return
}

get_real_physics_body_rect :: proc(body: Physics_Body) -> FRect {
    return rect_add_vector(body.rect, body.anchor^)
}
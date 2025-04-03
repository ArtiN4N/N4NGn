package ecs
import sdl "vendor:sdl3"
import g4n "../g4n"

PhysicsComponent :: struct {
    body: g4n.PhysicsBody,
    velocity: g4n.FVector,
    acceleration: g4n.FVector,
    velo_forces: [dynamic]g4n.Force,
    accel_forces: [dynamic]g4n.Force,
    mass: f32,
    // 0 for no bounce, 255 for max bounce
    bounciness: u8,
    collision_tier: u8,
}

create_physics_component_data :: proc(
    anchor: ^g4n.FVector, width, height, body_anchor_x, body_anchor_y, mass: f32, bounciness: u8
) -> (component: PhysicsComponent) {
    component.body = g4n.make_physics_body(anchor, width, height, body_anchor_x, body_anchor_y)

    component.velocity = g4n.FVECTOR_ZERO
    component.acceleration = g4n.FVECTOR_ZERO

    component.velo_forces = make([dynamic]g4n.Force)
    component.accel_forces = make([dynamic]g4n.Force)

    component.mass = mass
    component.bounciness = bounciness
    return
}
destroy_physics_component_data :: proc(component: ^PhysicsComponent) {
    delete(component.velo_forces)
    delete(component.accel_forces)
}




EdgeGrabComponent :: struct {
    is_grabbing: bool,
    trying_to_grab: bool,
    grabbed_tile: g4n.TVector,
}

create_edge_grab_component_data :: proc() -> (component: EdgeGrabComponent) {
    component.is_grabbing = false
    component.trying_to_grab = false
    component.grabbed_tile = g4n.TVECTOR_ZERO
    return
}
destroy_edge_grab_component_data :: proc(component: ^EdgeGrabComponent) {}




GravityComponent :: struct {
    gravity_value: f32,
}

create_gravity_component_data :: proc(g_value: f32) -> (component: GravityComponent) {
    component.gravity_value = g_value
    return
}
destroy_gravity_component_data :: proc(component: ^GravityComponent) {}




MovementDirectionComponent :: struct {
    direction: g4n.FVector,
}

create_movement_direction_component_data :: proc() -> (component: MovementDirectionComponent) {
    component.direction = g4n.FVector{0, 0}
    return
}
destroy_movement_direction_component_data :: proc(component: ^MovementDirectionComponent) {}




CoyoteTimeComponent :: struct {
    coyote_time: f32,
    timer: g4n.Timer,
}

create_coyote_time_component_data :: proc(coyote_time: f32) -> (component: CoyoteTimeComponent) {
    component.coyote_time = coyote_time
    component.timer = g4n.create_timer()
    return
}
destroy_coyote_time_component_data :: proc(component: ^CoyoteTimeComponent) {}




MovementComponent :: struct {
    speed: f32,
}

create_movement_component_data :: proc(speed: f32) -> (component: MovementComponent) {
    component.speed = speed
    return
}
destroy_movement_component_data :: proc(component: ^MovementComponent) {}




HumanoidMovementComponent :: struct {
    walk_speed: f32,
    run_speed: f32,
}

create_humanoid_movement_component_data :: proc(walk_s, run_s: f32) -> (component: HumanoidMovementComponent) {
    component.walk_speed = walk_s
    component.run_speed = run_s
    return
}
destroy_humanoid_movement_component_data :: proc(component: ^HumanoidMovementComponent) {}




JumpingComponent :: struct {
    jump_height: f32,
}

create_jumping_component_data :: proc(j_height: f32) -> (component: JumpingComponent) {
    component.jump_height = j_height
    return
}
destroy_jumping_component_data :: proc(component: ^JumpingComponent) {}
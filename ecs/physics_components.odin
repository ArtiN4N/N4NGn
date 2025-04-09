package ecs
import sdl "vendor:sdl3"
import g4n "../g4n"

PhysicsComponent :: struct {
    body: g4n.PhysicsBody,
    //velocity: g4n.FVector,
    //acceleration: g4n.FVector,
    velo_forces: [dynamic]g4n.Force,
    accel_forces: [dynamic]g4n.CompoundForce,

    suspended: bool,
    mass: f32,
    // 0 for no bounce, 255 for max bounce
    bounciness: u8,
    collision_tier: u8,
}

create_physics_component_data :: proc(
    anchor: ^g4n.FVector, width, height, body_anchor_x, body_anchor_y, mass: f32, bounciness: u8
) -> (component: PhysicsComponent) {
    component.body = g4n.make_physics_body(anchor, body_anchor_x, body_anchor_y, width, height)

    //component.velocity = g4n.FVECTOR_ZERO
    //component.acceleration = g4n.FVECTOR_ZERO

    component.velo_forces = make([dynamic]g4n.Force)
    component.accel_forces = make([dynamic]g4n.CompoundForce)

    component.suspended = false
    component.mass = mass
    component.bounciness = bounciness
    return
}
destroy_physics_component_data :: proc(component: ^PhysicsComponent) {
    delete(component.velo_forces)
    delete(component.accel_forces)
}

add_physics_component_vel_force :: proc(phys_c: ^PhysicsComponent, f: g4n.Force) -> ^g4n.Force {
    append(&phys_c.velo_forces, f)
    return &phys_c.velo_forces[len(phys_c.velo_forces) - 1]
}

add_physics_component_accel_force :: proc(phys_c: ^PhysicsComponent, f: g4n.CompoundForce) -> ^g4n.CompoundForce {
    i := append(&phys_c.accel_forces, f)
    return &phys_c.accel_forces[len(phys_c.accel_forces) - 1]
}

update_physics_component :: proc(phys_c: ^PhysicsComponent, pos_c: ^PositionComponent, dt: f32) {
    velocity := g4n.FVECTOR_ZERO

    for &accel in phys_c.accel_forces {
        velocity += g4n.apply_compound_force(&accel, dt) / phys_c.mass
    }

    for &velo in phys_c.velo_forces {
        velocity += g4n.apply_force(&velo, dt)
    }

    pos_c.physics_position += velocity * dt
}



EdgeGrabComponent :: struct {
    is_grabbing: bool,
    trying_to_grab: bool,
    grabbed_tile: g4n.TVector,
    tile_right: bool,
}

create_edge_grab_component_data :: proc() -> (component: EdgeGrabComponent) {
    component.is_grabbing = false
    component.trying_to_grab = false
    component.grabbed_tile = g4n.TVECTOR_ZERO
    return
}
destroy_edge_grab_component_data :: proc(component: ^EdgeGrabComponent) {}

update_edge_grab_component :: proc(eg_c: ^EdgeGrabComponent, target_tile: g4n.TVector) {
    //if eg_c.trying_to_grab
}



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
    running: bool,
    x_move_direction: i32,
    last_moved_right: bool,
}

humanoid_move_component_get_move_vector :: proc(move_c: HumanoidMovementComponent) -> g4n.FVector {
    speed := move_c.walk_speed
    if move_c.running { speed = move_c.run_speed }
    return g4n.FVector{f32(move_c.x_move_direction) * speed, 0}
}

humanoid_move_component_on_physics :: proc(move_c: ^HumanoidMovementComponent, phys_c: ^PhysicsComponent) {
    force_dir := humanoid_move_component_get_move_vector(move_c^)

    if move_c.last_moved_right && force_dir.x < 0 { move_c.last_moved_right = false }
    else if !move_c.last_moved_right && force_dir.x > 0 { move_c.last_moved_right = true }

    vel_force := g4n.Force{force_dir, -1}
    add_physics_component_vel_force(phys_c, vel_force)
}

set_humanoid_move_component_running :: proc(component: ^HumanoidMovementComponent, running: bool) {
    component.running = running
}

set_humanoid_move_component_xdir :: proc(component: ^HumanoidMovementComponent, xdir: i32) {
    component.x_move_direction = xdir
}

set_humanoid_move_component_last_moved :: proc(component: ^HumanoidMovementComponent, last_moved: bool) {
    component.last_moved_right = last_moved
}

create_humanoid_movement_component_data :: proc(walk_s, run_s: f32) -> (component: HumanoidMovementComponent) {
    component.walk_speed = walk_s
    component.run_speed = run_s
    component.running = false
    component.x_move_direction = 0
    component.last_moved_right = true
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
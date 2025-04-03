package ecs
import sdl "vendor:sdl3"

// REMEMBER TO ADD NEW COMPONENTS TO THE MAP
stock_ecs_state_component_ids :: proc(state: ^ECSState) {
    comp_id_counter := 0
    add_ecs_state_component_id(state, PositionComponent, &comp_id_counter)
    add_ecs_state_component_id(state, PhysicsComponent, &comp_id_counter)
    add_ecs_state_component_id(state, EdgeGrabComponent, &comp_id_counter)
    add_ecs_state_component_id(state, GravityComponent, &comp_id_counter)
    add_ecs_state_component_id(state, MovementDirectionComponent, &comp_id_counter)
    add_ecs_state_component_id(state, CoyoteTimeComponent, &comp_id_counter)
    add_ecs_state_component_id(state, MovementComponent, &comp_id_counter)
    add_ecs_state_component_id(state, HumanoidMovementComponent, &comp_id_counter)
    add_ecs_state_component_id(state, JumpingComponent, &comp_id_counter)
    add_ecs_state_component_id(state, RenderPhysicsComponent, &comp_id_counter)
    add_ecs_state_component_id(state, RenderComponent, &comp_id_counter)
}

// Entities - Components - Systems
ECSState :: struct {
    active_entities: EntityID,

    position_cc: ComponentCollection(PositionComponent),
    physics_cc: ComponentCollection(PhysicsComponent),
    edge_grab_cc: ComponentCollection(EdgeGrabComponent),
    gravity_cc: ComponentCollection(GravityComponent),
    movement_direction_cc: ComponentCollection(MovementDirectionComponent),
    coyote_time_cc: ComponentCollection(CoyoteTimeComponent),
    movement_cc: ComponentCollection(MovementComponent),
    humanoid_movement_cc: ComponentCollection(HumanoidMovementComponent),
    jumping_cc: ComponentCollection(JumpingComponent),
    render_cc: ComponentCollection(RenderComponent),
    render_physics_cc: ComponentCollection(RenderPhysicsComponent),

    component_ids: map[typeid]ComponentID,

    entity_bitsets: map[EntityID]bit_set[0..<MAX_COMPONENTS; u128],
}

add_ecs_state_component_id :: proc(state: ^ECSState, $T: typeid, counter: ^int) {
    state.component_ids[T] = counter^
    counter^ += 1
}

create_ecs_state :: proc() -> (state: ECSState) {
    state.active_entities = 0
    state.position_cc = create_component_collection(PositionComponent)

    
    state.component_ids = make(map[typeid]ComponentID)
    stock_ecs_state_component_ids(&state)

    state.entity_bitsets = make(map[EntityID]bit_set[0..<MAX_COMPONENTS; u128])

    return
}

destroy_ecs_state :: proc(ecs_state: ^ECSState) {
    destroy_component_collection(&ecs_state.position_cc)
    delete(ecs_state.component_ids)
    delete(ecs_state.entity_bitsets)
}
package ecs
import sdl "vendor:sdl3"
import g4n "../g4n"

// Entities - Components - Systems
ECSState :: struct {
    active_entities: EntityID,

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

destroy_ecs_component_data :: proc{
    destroy_physics_component_data,
	destroy_edge_grab_component_data,
	destroy_gravity_component_data,
	destroy_movement_direction_component_data,
	destroy_coyote_time_component_data,
	destroy_movement_component_data,
	destroy_humanoid_movement_component_data,
	destroy_jumping_component_data,
	destroy_render_component_data,
	destroy_render_physics_component_data,
}

destroy_ecs_component_collections :: proc(ecs_state: ^ECSState) {
    destroy_component_collection(&ecs_state.physics_cc)
	destroy_component_collection(&ecs_state.edge_grab_cc)
	destroy_component_collection(&ecs_state.gravity_cc)
	destroy_component_collection(&ecs_state.movement_direction_cc)
	destroy_component_collection(&ecs_state.coyote_time_cc)
	destroy_component_collection(&ecs_state.movement_cc)
	destroy_component_collection(&ecs_state.humanoid_movement_cc)
	destroy_component_collection(&ecs_state.jumping_cc)
	destroy_component_collection(&ecs_state.render_cc)
	destroy_component_collection(&ecs_state.render_physics_cc)
}

stock_ecs_state_component_ids :: proc(state: ^ECSState) {
    comp_id_counter := 0
    add_ecs_state_component_id(state, PhysicsComponent, &comp_id_counter)
	add_ecs_state_component_id(state, EdgeGrabComponent, &comp_id_counter)
	add_ecs_state_component_id(state, GravityComponent, &comp_id_counter)
	add_ecs_state_component_id(state, MovementDirectionComponent, &comp_id_counter)
	add_ecs_state_component_id(state, CoyoteTimeComponent, &comp_id_counter)
	add_ecs_state_component_id(state, MovementComponent, &comp_id_counter)
	add_ecs_state_component_id(state, HumanoidMovementComponent, &comp_id_counter)
	add_ecs_state_component_id(state, JumpingComponent, &comp_id_counter)
	add_ecs_state_component_id(state, RenderComponent, &comp_id_counter)
	add_ecs_state_component_id(state, RenderPhysicsComponent, &comp_id_counter)
}

stock_ecs_state_component_collections :: proc(state: ^ECSState) {
    state.physics_cc = create_component_collection(PhysicsComponent)
	state.edge_grab_cc = create_component_collection(EdgeGrabComponent)
	state.gravity_cc = create_component_collection(GravityComponent)
	state.movement_direction_cc = create_component_collection(MovementDirectionComponent)
	state.coyote_time_cc = create_component_collection(CoyoteTimeComponent)
	state.movement_cc = create_component_collection(MovementComponent)
	state.humanoid_movement_cc = create_component_collection(HumanoidMovementComponent)
	state.jumping_cc = create_component_collection(JumpingComponent)
	state.render_cc = create_component_collection(RenderComponent)
	state.render_physics_cc = create_component_collection(RenderPhysicsComponent)
}

destroy_entity :: proc(ecs_state: ^ECSState, entity: EntityID) {
    for key, value in ecs_state.component_ids {
        if value in ecs_state.entity_bitsets[entity] {
            switch key {
            case PhysicsComponent:
                destroy_ecs_component(ecs_state, entity, &ecs_state.physics_cc)
			case EdgeGrabComponent:
                destroy_ecs_component(ecs_state, entity, &ecs_state.edge_grab_cc)
			case GravityComponent:
                destroy_ecs_component(ecs_state, entity, &ecs_state.gravity_cc)
			case MovementDirectionComponent:
                destroy_ecs_component(ecs_state, entity, &ecs_state.movement_direction_cc)
			case CoyoteTimeComponent:
                destroy_ecs_component(ecs_state, entity, &ecs_state.coyote_time_cc)
			case MovementComponent:
                destroy_ecs_component(ecs_state, entity, &ecs_state.movement_cc)
			case HumanoidMovementComponent:
                destroy_ecs_component(ecs_state, entity, &ecs_state.humanoid_movement_cc)
			case JumpingComponent:
                destroy_ecs_component(ecs_state, entity, &ecs_state.jumping_cc)
			case RenderComponent:
                destroy_ecs_component(ecs_state, entity, &ecs_state.render_cc)
			case RenderPhysicsComponent:
                destroy_ecs_component(ecs_state, entity, &ecs_state.render_physics_cc)
            }
        }
    }
}
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
	position_cc: ComponentCollection(PositionComponent),
	render_cc: ComponentCollection(RenderComponent),
	render_physics_cc: ComponentCollection(RenderPhysicsComponent),

    entity_bitsets: [MAX_ENTITIES]bit_set[ComponentID],
}

ComponentID :: enum {
    Physics_CE,
	EdgeGrab_CE,
	Gravity_CE,
	MovementDirection_CE,
	CoyoteTime_CE,
	Movement_CE,
	HumanoidMovement_CE,
	Jumping_CE,
	Position_CE,
	Render_CE,
	RenderPhysics_CE,
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
	destroy_position_component_data,
	destroy_render_component_data,
	destroy_render_physics_component_data,
}

destroy_ecs_component_collections :: proc(ecs_state: ^ECSState) {
    destroy_component_collection(ecs_state^, &ecs_state.physics_cc)
	destroy_component_collection(ecs_state^, &ecs_state.edge_grab_cc)
	destroy_component_collection(ecs_state^, &ecs_state.gravity_cc)
	destroy_component_collection(ecs_state^, &ecs_state.movement_direction_cc)
	destroy_component_collection(ecs_state^, &ecs_state.coyote_time_cc)
	destroy_component_collection(ecs_state^, &ecs_state.movement_cc)
	destroy_component_collection(ecs_state^, &ecs_state.humanoid_movement_cc)
	destroy_component_collection(ecs_state^, &ecs_state.jumping_cc)
	destroy_component_collection(ecs_state^, &ecs_state.position_cc)
	destroy_component_collection(ecs_state^, &ecs_state.render_cc)
	destroy_component_collection(ecs_state^, &ecs_state.render_physics_cc)
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
	state.position_cc = create_component_collection(PositionComponent)
	state.render_cc = create_component_collection(RenderComponent)
	state.render_physics_cc = create_component_collection(RenderPhysicsComponent)
}

get_component_id :: proc(T: typeid) -> ComponentID {
	switch T {
    case PhysicsComponent:
        return .Physics_CE
	case EdgeGrabComponent:
        return .EdgeGrab_CE
	case GravityComponent:
        return .Gravity_CE
	case MovementDirectionComponent:
        return .MovementDirection_CE
	case CoyoteTimeComponent:
        return .CoyoteTime_CE
	case MovementComponent:
        return .Movement_CE
	case HumanoidMovementComponent:
        return .HumanoidMovement_CE
	case JumpingComponent:
        return .Jumping_CE
	case PositionComponent:
        return .Position_CE
	case RenderComponent:
        return .Render_CE
	case RenderPhysicsComponent:
        return .RenderPhysics_CE
	}

    // need to replace this with error or default case
	return .Position_CE
}

destroy_entity :: proc(ecs_state: ^ECSState, entity: EntityID) {
    for e in ComponentID {
        if e in ecs_state.entity_bitsets[entity] {
            switch e {
            case .Physics_CE:
                destroy_ecs_component(ecs_state, entity, &ecs_state.physics_cc)
			case .EdgeGrab_CE:
                destroy_ecs_component(ecs_state, entity, &ecs_state.edge_grab_cc)
			case .Gravity_CE:
                destroy_ecs_component(ecs_state, entity, &ecs_state.gravity_cc)
			case .MovementDirection_CE:
                destroy_ecs_component(ecs_state, entity, &ecs_state.movement_direction_cc)
			case .CoyoteTime_CE:
                destroy_ecs_component(ecs_state, entity, &ecs_state.coyote_time_cc)
			case .Movement_CE:
                destroy_ecs_component(ecs_state, entity, &ecs_state.movement_cc)
			case .HumanoidMovement_CE:
                destroy_ecs_component(ecs_state, entity, &ecs_state.humanoid_movement_cc)
			case .Jumping_CE:
                destroy_ecs_component(ecs_state, entity, &ecs_state.jumping_cc)
			case .Position_CE:
                destroy_ecs_component(ecs_state, entity, &ecs_state.position_cc)
			case .Render_CE:
                destroy_ecs_component(ecs_state, entity, &ecs_state.render_cc)
			case .RenderPhysics_CE:
                destroy_ecs_component(ecs_state, entity, &ecs_state.render_physics_cc)
            }
        }
    }
}
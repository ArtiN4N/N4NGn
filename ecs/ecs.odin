package ecs
import sdl "vendor:sdl3"

// see ECSState in by_component_code.odin

// see stock_ecs_state_component_ids in by_component_code.odin

// see stock_ecs_state_component_collections

create_ecs_state :: proc() -> (e_state: ECS_State) {
    e_state.active_entities = 0

    stock_ecs_state_component_collections(&e_state)
    return
}

destroy_ecs_state :: proc(e_state: ^ECS_State) {
    destroy_ecs_component_collections(e_state)
}

check_entity_has_component :: proc(e_state: ^ECS_State, component: ComponentID, entity: EntityID) -> bool {
    return component in e_state.entity_bitsets[entity]
}

// see destroy_ecs_component_collections in by_component_code.odin
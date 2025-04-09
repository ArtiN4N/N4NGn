package ecs
import sdl "vendor:sdl3"

// see ECSState in by_component_code.odin

// see stock_ecs_state_component_ids in by_component_code.odin

// see stock_ecs_state_component_collections

create_ecs_state :: proc() -> (state: ECSState) {
    state.active_entities = 0

    stock_ecs_state_component_collections(&state)
    return
}

destroy_ecs_state :: proc(ecs_state: ^ECSState) {
    destroy_ecs_component_collections(ecs_state)
}

check_entity_has_component :: proc(e_state: ^ECSState, component: ComponentID, entity: EntityID) -> bool {
    return component in e_state.entity_bitsets[entity]
}

// see destroy_ecs_component_collections in by_component_code.odin
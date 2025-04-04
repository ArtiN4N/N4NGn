package ecs
import sdl "vendor:sdl3"

// see ECSState in by_component_code.odin

add_ecs_state_component_id :: proc(state: ^ECSState, $T: typeid, counter: ^int) {
    state.component_ids[T] = counter^
    counter^ += 1
}

// see stock_ecs_state_component_ids in by_component_code.odin

// see stock_ecs_state_component_collections

create_ecs_state :: proc() -> (state: ECSState) {
    state.active_entities = 0

    stock_ecs_state_component_collections(&state)
    
    state.component_ids = make(map[typeid]ComponentID)
    stock_ecs_state_component_ids(&state)

    state.entity_bitsets = make(map[EntityID]bit_set[0..<MAX_COMPONENTS; u128])

    return
}

destroy_ecs_state :: proc(ecs_state: ^ECSState) {
    destroy_ecs_component_collections(ecs_state)
    delete(ecs_state.component_ids)
    delete(ecs_state.entity_bitsets)
}

// see destroy_ecs_component_collections in by_component_code.odin
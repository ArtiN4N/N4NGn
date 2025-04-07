package ecs
import sdl "vendor:sdl3"
import queue "core:container/queue"

MAX_COMPONENTS :: 128

ComponentCollection :: struct(ComponentType: typeid) {
    components: [MAX_ENTITIES]ComponentType,
    free_components: queue.Queue(u32),
    highest_idx: u32,
    sparse_set: [MAX_ENTITIES]u32,
}

get_entities_component_idx :: proc(collec: ComponentCollection($T), entity: EntityID) -> u32 {
    return collec.sparse_set[entity]
}

get_entities_component :: proc(collec: ^ComponentCollection($T), entity: EntityID) -> ^T {
    return &collec.components[get_entities_component_idx(collec^, entity)]
}

create_component_collection :: proc($T: typeid) -> (collection: ComponentCollection(T)) {
    collection.components = {}
    queue.init(&collection.free_components)
    collection.highest_idx = 0
    return
}

destroy_component_collection :: proc(ecs_state: ECSState, collection: ^ComponentCollection($T)) {
    l := queue.len(collection.free_components)
    skip_eles : [MAX_ENTITIES]bool
    for i in 0..<l {
        queue.peek_front(&collection.free_components)
        skip_eles[i] = true
    }

    for i in 0..<collection.highest_idx {
        if skip_eles[i] { continue }
        destroy_ecs_component_data(&collection.components[i])
    }

    queue.destroy(&collection.free_components)
}

new_ecs_component_index :: proc(cc: ^ComponentCollection($T)) -> u32 {
    if queue.len(cc.free_components) > 0 { return queue.pop_front(&cc.free_components) }
    
    ret_idx := cc.highest_idx
    cc.highest_idx += 1
    return ret_idx
}

attach_ecs_component :: proc(
    ecs_state: ^ECSState, entity: EntityID,
    $T: typeid, cc: ^ComponentCollection(T), component: T = {}
) {
    idx := new_ecs_component_index(cc)
    cc.components[idx] = component
    cc.sparse_set[entity] = idx
    ecs_state.entity_bitsets[entity] += {get_component_id(T)}
}

destroy_ecs_component :: proc(
    ecs_state: ^ECSState, entity: EntityID,
    cc: ^ComponentCollection($T)
) {
    idx := cc.sparse_set[entity]
    destroy_ecs_component_data(&cc.components[idx])
    ecs_state.entity_bitsets[entity] -= {get_component_id(T)}
    
    queue.append_elem(&cc.free_components, idx)
}

// see destroy_ecs_component_data in by_component_code.odin
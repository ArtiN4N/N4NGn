package ecs
import sdl "vendor:sdl3"
import queue "core:container/queue"

ComponentID :: int
MAX_COMPONENTS :: 128

// REMEMBER TO ADD NEW COMPONENTS TO THE DESTROY OVERLOADING PROCEDURE
destroy_ecs_component_data :: proc{
    destroy_position_component_data,
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

ComponentCollection :: struct(ComponentType: typeid) {
    components: [MAX_ENTITIES]ComponentType,
    free_components: queue.Queue(u32),
    count: u32,
    sparse_set: map[EntityID]u32,
}

create_component_collection :: proc($T: typeid) -> (collection: ComponentCollection(T)) {
    collection.components = {}
    queue.init(&collection.free_components)
    collection.count = 0
    collection.sparse_set = make(map[EntityID]u32)
    return
}

destroy_component_collection :: proc(collection: ^ComponentCollection($T)) {
    delete(collection.sparse_set)
    queue.destroy(&collection.free_components)
    for i in 0..<collection.count {
        destroy_ecs_component_data(&collection.components[i])
    }
}

new_ecs_component_index :: proc(cc: ^ComponentCollection($T)) -> u32 {
    if queue.len(cc.free_components) > 0 { return queue.pop_front(cc.free_components) }
    
    ret_idx := cc.count
    cc.count += 1
    return ret_idx
}

attach_ecs_component :: proc(
    ecs_state: ^ECSState, entity: EntityID,
    $T: typeid, cc: ^ComponentCollection(T), component: T = {}
) {
    idx := new_ecs_component_index(T, &cc)
    cc.components[idx] = component
    cc.sparse_set[entity] = idx
    ecs_state.entity_bitsets[entity] += {ecs_state.component_ids[T]}
}

destroy_ecs_component :: proc(
    ecs_state: ^ECSState, entity: EntityID,
    cc: ^ComponentCollection($T)
) {
    idx := cc.sparse_set[entity]
    destroy_ecs_component_data(cc.components[idx])
    delete_key(cc.sparse_set, entity)
    ecs_state.entity_bitsets[entity] -= {ecs_state.component_ids[T]}
    cc.count -= 1
    
    queue.append_elem(&cc.free_components, idx)
}
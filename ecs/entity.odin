package ecs
import sdl "vendor:sdl3"
import g4n "../g4n"

EntityID :: u32

MAX_ENTITIES :: 512

create_entity :: proc(ecs_state: ^ECSState) -> (id: EntityID, ok: bool) {
    if ecs_state.active_entities == MAX_ENTITIES {
        g4n.log("Error! Trying to create more entities than allowed!")
        return 0, false
    }

    id = ecs_state.active_entities
    ecs_state.active_entities += 1

    return id, ok
}

// see destroy_entity in by_component_code.odin
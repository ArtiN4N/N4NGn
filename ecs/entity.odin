package ecs
import sdl "vendor:sdl3"
import g4n "../g4n"
import "core:log"

EntityID :: u32

MAX_ENTITIES :: 512

create_entity :: proc(ecs_state: ^ECS_State) -> (id: EntityID, ok: bool) {
    if ecs_state.active_entities == MAX_ENTITIES {
        log.logf(.Error, "Tried creating an entity when there is no space for one.")
        return 0, false
    }
    ok = true

    id = ecs_state.active_entities
    ecs_state.active_entities += 1

    return id, ok
}

// see destroy_entity in by_component_code.odin
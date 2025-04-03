package ecs
import sdl "vendor:sdl3"
import g4n "../g4n"

PositionComponent :: struct {
    physics_position: g4n.FVector,
}

get_logical_position_from_component :: proc(component: PositionComponent) -> g4n.IVector {
    return g4n.to_ivector(component.physics_position)
}

create_position_component_data :: proc(init_x : f32 = 0, init_y : f32 = 0) -> (component: PositionComponent) {
    component.physics_position = g4n.FVector{init_x, init_y}
    return
}

destroy_position_component_data :: proc(component: ^PositionComponent) {}
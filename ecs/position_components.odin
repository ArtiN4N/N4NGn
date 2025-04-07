package ecs
import sdl "vendor:sdl3"
import g4n "../g4n"

PositionComponent :: struct {
    physics_position: g4n.FVector,
    logic_position: g4n.IVector,
}

update_logical_position_from_component :: proc(component: ^PositionComponent) {
    component.logic_position = g4n.to_ivector(component.physics_position)
}

create_position_component_data :: proc(init_x : i32 = 0, init_y : i32 = 0) -> (component: PositionComponent) {
    component.logic_position = g4n.IVector{init_x, init_y}
    component.physics_position = g4n.to_fvector(component.logic_position)
    return
}

destroy_position_component_data :: proc(component: ^PositionComponent) {}
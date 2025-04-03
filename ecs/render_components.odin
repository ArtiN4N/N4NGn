package ecs
import sdl "vendor:sdl3"
import g4n "../g4n"

RenderComponent :: struct {
    in_camera: bool,
    camera: ^g4n.Camera
}

set_render_component_camera :: proc(component: ^RenderComponent, camera: ^g4n.Camera) {
    component.in_camera = true
    component.camera = camera
}

create_render_component_data :: proc() -> (component: RenderComponent) {
    component.in_camera = false
    component.camera = nil
    return
}
destroy_render_component_data :: proc(component: ^RenderComponent) {}




RenderPhysicsComponent :: struct {
    color: sdl.Color
}

create_render_physics_component_data :: proc(color: sdl.Color) -> (component: RenderPhysicsComponent) {
    component.color = color
    return
}
destroy_render_physics_component_data :: proc(component: ^RenderPhysicsComponent) {}
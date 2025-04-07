package ecs
import sdl "vendor:sdl3"
import g4n "../g4n"

RenderComponent :: struct {
    in_camera: bool,
    camera: ^g4n.Camera,
    texture: ^sdl.Texture,
    texture_dest: g4n.IRect
}

set_render_component_camera :: proc(component: ^RenderComponent, camera: ^g4n.Camera) {
    component.in_camera = true
    component.camera = camera
}

create_render_component_data :: proc(
    width, height: i32, texture: ^sdl.Texture = nil, in_camera: bool = false, camera: ^g4n.Camera = nil
) -> (component: RenderComponent) {
    component.in_camera = in_camera
    component.camera = camera
    component.texture = texture
    component.texture_dest = g4n.IRect{0, 0, width, height}
    return
}
destroy_render_component_data :: proc(component: ^RenderComponent) {}

render_render_component :: proc(renderer: ^sdl.Renderer, rend_c: RenderComponent, pos_c: PositionComponent) {
    texture_dest := rend_c.texture_dest
    texture_dest.x = i32(pos_c.physics_position.x)
    texture_dest.y = i32(pos_c.physics_position.y)
    if rend_c.in_camera {
        g4n.render_texture_via_camera(rend_c.camera^, renderer, rend_c.texture, nil, &texture_dest)
    }
}



RenderPhysicsComponent :: struct {
    color: sdl.Color
}

create_render_physics_component_data :: proc(color: sdl.Color) -> (component: RenderPhysicsComponent) {
    component.color = color
    return
}
destroy_render_physics_component_data :: proc(component: ^RenderPhysicsComponent) {}
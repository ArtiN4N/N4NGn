package ecs
import sdl "vendor:sdl3"
import g4n "../g4n"

RenderComponent :: struct {
    in_camera: bool,
    camera: ^g4n.Camera,
    texture_key: g4n.Texture_Key,
    texture_dest: g4n.IRect
}

set_render_component_camera :: proc(component: ^RenderComponent, camera: ^g4n.Camera) {
    component.in_camera = true
    component.camera = camera
}

create_render_component_data :: proc(
    width, height: i32, tkey: g4n.Texture_Key, in_camera: bool = false, camera: ^g4n.Camera = nil
) -> (component: RenderComponent) {
    component.in_camera = in_camera
    component.camera = camera
    component.texture_key = tkey
    component.texture_dest = g4n.IRect{0, 0, width, height}
    return
}
destroy_render_component_data :: proc(component: ^RenderComponent) {}

render_render_component :: proc(renderer: ^sdl.Renderer, tsets: g4n.Texture_Set_Map, rend_c: RenderComponent, pos_c: PositionComponent) {
    texture := g4n.get_tile_texture_with_key(tsets, rend_c.texture_key)
    texture_dest := g4n.rect_add_vector(rend_c.texture_dest, pos_c.logic_position)
    if rend_c.in_camera {
        g4n.render_texture_via_camera(rend_c.camera^, renderer, texture, nil, &texture_dest)
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
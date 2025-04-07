package g4n
import sdl "vendor:sdl3"

// A camera has a view of the game's logic space.
// It keeps a pointer to a vector as its anchor. This anchor is the center of the camera.
// The cameras view is a source rectangle, using the sum of its source offset as its position,
// and its source size as its size.
Camera :: struct {
    box: IRect,
    anchor: ^IVector
}

// By default, the offset of the camera is the negative of half its size.
// Logically, this means the camera's anchor is in the center of the camera.
// A custom offset can be applied, which is added on top of this default size-based offset.
create_camera :: proc(width, height: i32, anchor: ^IVector, offset: IVector = IVECTOR_ZERO) -> (camera: Camera) {
    camera.box = { 0, 0, width, height }
    camera.box = rect_add_vector(camera.box, offset)
    camera.anchor = anchor

    log("Created camera.")

    return
}

get_camera_shift_position :: proc(cam: Camera) -> IVector {
    size_offset := vector_div_scalar(IVector{cam.box.w - 1, cam.box.h - 1}, 2)
    return vector_add(size_offset, -cam.anchor^)
}

get_camera_real_position :: proc(cam: Camera) -> IVector {
    return vector_add(get_rect_position(cam.box), cam.anchor^)
}

get_camera_real_rectangle :: proc(cam: Camera) -> IRect {
    pos := get_camera_real_position(cam)
    return IRect{ pos.x, pos.y, cam.box.w, cam.box.h}
}

is_point_in_camera :: proc(cam: Camera, pos: IVector) -> bool {
    return rect_contains_vector(get_camera_real_rectangle(cam), pos)
}
import "core:fmt"
is_rectangle_in_camera :: proc(cam: Camera, rect: IRect) -> bool {
    return rects_collide(get_camera_real_rectangle(cam), rect)
}

// Does an offset to the texture to be drawn before rendering, translating it into the screen.
// Texture is drawn as if there is an actual camera moving around the logical world.
render_texture_via_camera :: proc(cam: Camera, renderer: ^sdl.Renderer, tex: ^sdl.Texture, tex_src, tex_dest: ^IRect) {
    if !is_rectangle_in_camera(cam, tex_dest^) { return }

    tex_src, tex_dest := tex_src, tex_dest

    real_pos := get_camera_shift_position(cam)
    tex_dest^ = rect_add_vector(tex_dest^, real_pos)

    fsrc := FRECT_ZERO
    fdest := FRECT_ZERO

    draw_src : ^sdl.FRect = nil
    draw_dest : ^sdl.FRect = nil

    if tex_src != nil {
        fsrc = to_sdl_frect(tex_src^)
        draw_src = &fsrc
    }
    if tex_dest != nil {
        fdest = to_sdl_frect(tex_dest^)
        draw_dest = &fdest
    }

    sdl.RenderTexture(renderer, tex, draw_src, draw_dest)
}

render_rect_via_camera :: proc(cam: Camera, renderer: ^sdl.Renderer, rect: sdl.Rect) {
    if !is_rectangle_in_camera(cam, rect) { return }

    rect := rect

    real_pos := get_camera_real_position(cam)
    rect_add_vector(rect, -real_pos)

    frect := to_frect(rect)
    sdl.RenderRect(renderer, &frect)
}
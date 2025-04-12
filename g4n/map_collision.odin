package g4n
import olog "core:log"
import "core:fmt"

line_collides_map :: proc(line: TLine, tmap: TileMap, tinfo: TileInfo, c_tier: u8) -> bool {
    min_bound, max_bound := get_map_indecies_bound_by_positions(line.a, line.b, tmap.tile_size)

    for x := min_bound.x; x <= max_bound.x; x += 1 {
        for y := min_bound.y; y <= max_bound.y; y += 1 {
            tile_rect := get_map_index_rect(x, y, tmap.tile_size)

            if line_intersects_rect(line, tile_rect) && c_tier < tinfo.collision_tier[tmap.set[x][y]] {
                return true
            }
        }
    }
    return false
}

rect_collides_map :: proc(rect: TRect, tmap: TileMap, tinfo: TileInfo, c_tier: u8) -> bool {
    corners := get_rect_corners(rect)
    min_bound, max_bound := get_map_indecies_bound_by_positions(corners[.NW], corners[.SE], tmap.tile_size)

    for x := min_bound.x; x <= max_bound.x; x += 1 {
        for y := min_bound.y; y <= max_bound.y; y += 1 {
            tile_rect := get_map_index_rect(x, y, tmap.tile_size)

            if rects_collide(rect, tile_rect) && c_tier < tinfo.collision_tier[tmap.set[x][y]] {
                return true
            }
        }
    }

    return false
}

tilemap_rect_movement_collision_occurs :: proc(rect: TRect, p_pos: TVector, tmap: TileMap, tinfo: TileInfo, c_tier: u8) -> bool {
    if get_rect_position(rect) == p_pos { return false }

    rect := rect
    p_rect := rect_with_position(rect, p_pos)
    if rect_collides_map(p_rect, tmap, tinfo, c_tier) { return true }

    corners := get_rect_corners(rect)
    p_corners := get_rect_corners(p_rect)

    if line_collides_map(TLine{corners[.NE], p_corners[.NE]}, tmap, tinfo, c_tier) { return true }
    if line_collides_map(TLine{corners[.NW], p_corners[.NW]}, tmap, tinfo, c_tier) { return true }
    if line_collides_map(TLine{corners[.SW], p_corners[.SW]}, tmap, tinfo, c_tier) { return true }
    if line_collides_map(TLine{corners[.SE], p_corners[.SE]}, tmap, tinfo, c_tier) { return true }

    max_x_rect_corners: ^TRectCorners
    min_x_rect_corners: ^TRectCorners
    max_y_rect_corners: ^TRectCorners
    min_y_rect_corners: ^TRectCorners

    if corners[.NE].x > p_corners[.NE].x { max_x_rect_corners = &corners }
    else                                 { max_x_rect_corners = &p_corners }

    if corners[.SW].x < p_corners[.SW].x { min_x_rect_corners = &corners }
    else                                 { min_x_rect_corners = &p_corners }

    if corners[.SW].y > p_corners[.SW].y { max_y_rect_corners = &corners }
    else                                 { max_y_rect_corners = &p_corners }

    if corners[.NE].y < p_corners[.NE].y { min_y_rect_corners = &corners }
    else                                 { min_y_rect_corners = &p_corners }

    max_x_sample := convert_position_to_map_index(max_x_rect_corners[.NE], tmap.tile_size).x
    min_x_sample := convert_position_to_map_index(min_x_rect_corners[.SW], tmap.tile_size).x
    max_y_sample := convert_position_to_map_index(max_y_rect_corners[.SW], tmap.tile_size).y
    min_y_sample := convert_position_to_map_index(min_y_rect_corners[.NE], tmap.tile_size).y

    min_bound := TVector{min_x_sample, min_y_sample}
    max_bound := TVector{max_x_sample, max_y_sample}

    edge_line_a, mid_line, edge_line_b := get_frect_movement_defining_lines(to_frect(rect), to_fvector(p_pos))
    max_d := lines_distance(edge_line_a, edge_line_b)

    for x := min_bound.x; x <= max_bound.x; x += 1 {
        for y := min_bound.y; y <= max_bound.y; y += 1 {
            tile_rect := get_map_index_rect(x, y, tmap.tile_size)

            if !line_intersects_rect(mid_line, to_frect(tile_rect)) {
                if line_rectangle_distance(edge_line_a, to_frect(tile_rect)) > max_d || line_rectangle_distance(edge_line_b, to_frect(tile_rect)) > max_d {
                    continue
                }
            }

            if c_tier < tinfo.collision_tier[tmap.set[x][y]] {
                return true
            }
        }
    }

    return false
}
package g4n

line_collides_map :: proc( line: FLine, tmap: TileMap, tinfo: TileInfo, line_collision_tier: u8) -> bool {

    //line := cap_negative_line_coords(line)
    
    f_tile_size := f32(tmap.tile_size)

    bounding_pos1 := convert_vector_by_map_dimensions(line.a, f_tile_size)
    bounding_pos2 := convert_vector_by_map_dimensions(line.b, f_tile_size)

    min_bounding_x := min(bounding_pos1.x, bounding_pos2.x)
    max_bounding_x := max(bounding_pos1.x, bounding_pos2.x)

    min_bounding_y := min(bounding_pos1.y, bounding_pos2.y)
    max_bounding_y := max(bounding_pos1.y, bounding_pos2.y)

    tile_rect := FRect{ f_tile_size / 2, f_tile_size / 2, f_tile_size, f_tile_size}
    for i := min_bounding_x; i <= max_bounding_x; i += 1 {
        tile_rect.x += f_tile_size
        for j := min_bounding_y; j <= max_bounding_y; j += 1 {
            tile_rect.y += f_tile_size

            i := u32(i)
            j := u32(j)

            if line_intersects_rect(line, tile_rect) && line_collision_tier < tinfo.collision_tier[tmap.set[i][j]] {
                return true
            }
        }
    }

    return false
}

rect_collides_map :: proc(rect: FRect, tmap: TileMap, tinfo: TileInfo, rect_collision_tier: u8) -> bool {
    f_tile_size := f32(tmap.tile_size)

    corners := get_rect_corners(rect)

    min_bounding_x := convert_vector_by_map_dimensions(corners[.NW], f_tile_size).x
    max_bounding_x := convert_vector_by_map_dimensions(corners[.NE], f_tile_size).x

    min_bounding_y := convert_vector_by_map_dimensions(corners[.NE], f_tile_size).y
    max_bounding_y := convert_vector_by_map_dimensions(corners[.SE], f_tile_size).y

    tile_rect := FRect{ f_tile_size / 2, f_tile_size / 2, f_tile_size, f_tile_size}
    for i := min_bounding_x; i <= max_bounding_x; i += 1 {
        tile_rect.x += f_tile_size
        for j := min_bounding_y; j <= max_bounding_y; j += 1 {
            tile_rect.y += f_tile_size

            i := u32(i)
            j := u32(j)

            if rects_collide(rect, tile_rect) && rect_collision_tier < tinfo.collision_tier[tmap.set[i][j]] {
                return true
            }
        }
    }

    return false
}

tilemap_rect_movement_collision_occurs :: proc(rect: FRect, new_position: FVector, tmap: TileMap, tinfo: TileInfo, rect_collision_tier: u8) -> bool {
    if get_rect_position(rect) == new_position { return false }

    rect := rect

    p_rect := rect
    p_rect.x = new_position.x
    p_rect.y = new_position.y

    if rect_collides_map(p_rect, tmap, tinfo, rect_collision_tier) { return true }

    corners := get_rect_corners(rect)
    p_corners := get_rect_corners(p_rect)

    if line_collides_map(FLine{corners[.NE], p_corners[.NE]}, tmap, tinfo, rect_collision_tier) { return true }
    if line_collides_map(FLine{corners[.NW], p_corners[.NW]}, tmap, tinfo, rect_collision_tier) { return true }
    if line_collides_map(FLine{corners[.SW], p_corners[.SW]}, tmap, tinfo, rect_collision_tier) { return true }
    if line_collides_map(FLine{corners[.SE], p_corners[.SE]}, tmap, tinfo, rect_collision_tier) { return true }

    f_tile_size := f32(tmap.tile_size)

    max_x_rect_corners: ^FRectCorners
    min_x_rect_corners: ^FRectCorners
    max_y_rect_corners: ^FRectCorners
    min_y_rect_corners: ^FRectCorners

    if corners[.NE].x > p_corners[.NE].x { max_x_rect_corners = &corners }
    else { max_x_rect_corners = &p_corners }

    if corners[.SW].x < p_corners[.SW].x { min_x_rect_corners = &corners }
    else { min_x_rect_corners = &p_corners }

    if corners[.SW].y > p_corners[.SW].y { max_y_rect_corners = &corners }
    else { max_y_rect_corners = &p_corners }

    if corners[.NE].y < p_corners[.NE].y { min_y_rect_corners = &corners }
    else { min_y_rect_corners = &p_corners }

    max_x_sample := convert_vector_by_map_dimensions(max_x_rect_corners[.NE], f_tile_size).x
    min_x_sample := convert_vector_by_map_dimensions(min_x_rect_corners[.SW], f_tile_size).x

    max_y_sample := convert_vector_by_map_dimensions(max_y_rect_corners[.SW], f_tile_size).y
    min_y_sample := convert_vector_by_map_dimensions(min_y_rect_corners[.NE], f_tile_size).y

    edge_line_a, mid_line, edge_line_b := get_rect_movement_defining_lines(rect, new_position)
    max_d := lines_distance(edge_line_a, edge_line_b)

    tile_rect := FRect{ f_tile_size / 2, f_tile_size / 2, f_tile_size, f_tile_size}
    for i := min_x_sample; i <= max_x_sample; i += 1 {
        tile_rect.x += f_tile_size
        for j := min_y_sample; j <= max_y_sample; j += 1 {
            tile_rect.y += f_tile_size
            if !line_intersects_rect(mid_line, tile_rect) {
                if line_rectangle_distance(edge_line_a, tile_rect) > max_d || line_rectangle_distance(edge_line_b, tile_rect) > max_d {
                    //if !rects_collide(rect, tile_rect) && !rects_collide(p_rect, tile_rect) { // might be unneccesary
                        continue
                    //}
                }
            }
            // test for collision
            i := u32(i)
            j := u32(j)

            if rect_collision_tier < tinfo.collision_tier[tmap.set[i][j]] {
                return true
            }
        }
    }

    return false
}
package g4n
import "core:math"

MAX_RECT_DISTANCE_FOR_INCREMENT_CORRECTION :: DEFAULT_TILE_SIZE * 5

tilemap_correct_rect_collision :: proc(rect: TRect, new_position: TVector, tmap: TileMap, tinfo: TileInfo, c_tier: u8) {
    if (!tilemap_rect_movement_collision_occurs(rect, new_position, tmap, tinfo, c_tier)) { return }

    //movement_dist := vector_dist(get_rect_position(rect), new_position)

    //if movement_dist < MAX_RECT_DISTANCE_FOR_INCREMENT_CORRECTION {
    tilemap_increment_rect_collision_correction(rect, new_position, tmap, tinfo, c_tier)
    //}
}

tilemap_increment_rect_collision_correction :: proc(
    rect: TRect, prospect_pos: TVector, tmap: TileMap, tinfo: TileInfo, c_tier: u8
) -> (correct_pos: TVector, collided_x, collided_y: bool) {
    orig_pos := get_rect_position(rect)

    if rect_collides_map(rect, tmap, tinfo, c_tier) {
        collided_x = true
        collided_y = true
        return
    }
    if orig_pos == correct_pos {
        collided_x = false
        collided_y = false
        return
    }

    prospect_pos := to_ivector(prospect_pos)

    move_diff := vector_sub(prospect_pos, to_ivector(orig_pos))
    abs_move_diff := vector_abs(move_diff)

    prospect_pos = to_ivector(orig_pos)
    next_prospect_pos := to_ivector(orig_pos)

    tile_subdiv := max(tmap.tile_size / 2, 1)
    diff_subdiv := IVector{max(abs_move_diff.x / 2, 1), max(abs_move_diff.y / 2, 1)}

    subdiv := IVector{min(i32(tile_subdiv), diff_subdiv.x), min(i32(tile_subdiv), diff_subdiv.y)}

    if move_diff.x < 0 { subdiv.x *= -1 }
    if move_diff.y < 0 { subdiv.y *= -1 }

    subdiv_polarity := IVector{abs(subdiv.x) / subdiv.x, abs(subdiv.y) / subdiv.y}

    min_subdiv : i32 : 1

    iterating_x : bool = abs_move_diff.x > 0
    iterating_y : bool = abs_move_diff.y > 0

    for iterating_x || iterating_y {
        if iterating_x {
            next_prospect_pos.x = prospect_pos.x + subdiv.x
            
            old_rect := rect_with_position(rect, to_tvector(prospect_pos))
            new_rect := rect_with_position(rect, to_tvector(IVector{next_prospect_pos.x, prospect_pos.y}))

            if rect_collides_map(new_rect, tmap, tinfo, c_tier) {
                if abs(subdiv.x) == abs(min_subdiv) {
                    iterating_x = false
                    collided_x = true
                } else {
                    subdiv.x /= 2
                    if abs(subdiv.x) < abs(min_subdiv) { subdiv.x = min_subdiv * subdiv_polarity.x }
                }
            } else {
                prospect_pos.x = next_prospect_pos.x
            }

            next_c_total_diff := abs(next_prospect_pos.x - i32(orig_pos.x))
            if next_c_total_diff > abs_move_diff.x {
                prospect_pos.x = prospect_pos.x
                iterating_x = false
                collided_x = false
            }
        }

        if iterating_y {
            next_prospect_pos.y = prospect_pos.y + subdiv.y
            
            old_rect := rect_with_position(rect, to_tvector(prospect_pos))
            new_rect := rect_with_position(rect, to_tvector(IVector{prospect_pos.x, next_prospect_pos.y}))

            if rect_collides_map(new_rect, tmap, tinfo, c_tier) {
                if abs(subdiv.y) == abs(min_subdiv) {
                    iterating_y = false
                    collided_y = true
                } else {
                    subdiv.y /= 2
                    if abs(subdiv.y) < abs(min_subdiv) { subdiv.y = min_subdiv * subdiv_polarity.y }
                }
            } else {
                prospect_pos.y = next_prospect_pos.y
            }

            next_c_total_diff := abs(next_prospect_pos.y - i32(orig_pos.y))
            if next_c_total_diff > abs_move_diff.y {
                prospect_pos.y = prospect_pos.y
                iterating_y = false
                collided_y = false
            }
        }
    }

    correct_pos = to_tvector(prospect_pos)

    return
}

package g4n
import "core:math"

MAX_RECT_DISTANCE_FOR_INCREMENT_CORRECTION :: DEFAULT_TILE_SIZE * 5

tilemap_correct_rect_collision :: proc(rect: FRect, new_position: FVector, tmap: TileMap, tinfo: TileInfo, rect_collision_tier: u8) {
    if (!tilemap_rect_movement_collision_occurs(rect, new_position, tmap, tinfo, rect_collision_tier)) { return }

    //movement_dist := vector_dist(get_rect_position(rect), new_position)

    //if movement_dist < MAX_RECT_DISTANCE_FOR_INCREMENT_CORRECTION {
    tilemap_increment_rect_collision_correction(rect, new_position, tmap, tinfo, rect_collision_tier)
    //}
}

tilemap_increment_rect_collision_correction :: proc(
    rect: FRect, prospect_pos: FVector, tmap: TileMap, tinfo: TileInfo, rect_collision_tier: u8
) -> (corrected_pos: FVector, collided_x, collided_y: bool) {
    o_pos := get_rect_position(rect)

    move_diff := vector_sub(prospect_pos, o_pos)
    abs_move_diff := vector_abs(move_diff)

    tile_subdiv := math.floor(f32(tmap.tile_size) / 2)
    diff_subdiv := FVector{math.floor(move_diff.x / 2), math.floor(move_diff.y / 2)}

    subdiv := FVector{min(tile_subdiv, diff_subdiv.x), min(tile_subdiv, diff_subdiv.y)}

    if move_diff.x < 0 { subdiv.x *= -1 }
    if move_diff.y < 0 { subdiv.y *= -1 }

    subdiv_polarity := FVector{abs(subdiv.x) / subdiv.x, abs(subdiv.y) / subdiv.y}

    min_subdiv : f32 = 0.9

    c_pos := o_pos
    next_c_pos := o_pos

    iterating_x : bool = move_diff.x > 0
    iterating_y : bool = move_diff.y > 0

    for iterating_x || iterating_y {
        if iterating_x {
            next_c_pos.x = c_pos.x + subdiv.x
            old_rect := FRect{c_pos.x, c_pos.y, rect.w, rect.h}
            new_rect := FRect{next_c_pos.x, c_pos.y, rect.w, rect.h}

            if rect_collides_map(new_rect, tmap, tinfo, rect_collision_tier) {
                if subdiv.x == min_subdiv {
                    c_pos.x = math.floor(c_pos.x)
                    iterating_x = false
                    collided_x = true
                } else {
                    subdiv.x /= 2
                    if abs(subdiv.x) < abs(min_subdiv) { subdiv.x = min_subdiv * subdiv_polarity.x }
                }
            } else {
                c_pos.x = next_c_pos.x
            }

            next_c_total_diff := abs(next_c_pos.x - o_pos.x)
            if next_c_total_diff > abs_move_diff.x {
                c_pos.x = prospect_pos.x
                iterating_x = false
                collided_x = false
            }
        }

        if iterating_y {
            next_c_pos.y = c_pos.y + subdiv.y
            old_rect := FRect{c_pos.x, c_pos.y, rect.w, rect.h}
            new_rect := FRect{c_pos.x, next_c_pos.y, rect.w, rect.h}

            if rect_collides_map(new_rect, tmap, tinfo, rect_collision_tier) {
                if subdiv.y == min_subdiv {
                    c_pos.y = math.floor(c_pos.y)
                    iterating_y = false
                    collided_y = true
                } else {
                    subdiv.y /= 2
                    if abs(subdiv.y) < abs(min_subdiv) { subdiv.y = min_subdiv * subdiv_polarity.y }
                }
            } else {
                c_pos.y = next_c_pos.y
            }

            next_c_total_diff := abs(next_c_pos.y - o_pos.y)
            if next_c_total_diff > abs_move_diff.y {
                c_pos.y = prospect_pos.y
                iterating_y = false
                collided_y = false
            }
        }
    }

    return
}

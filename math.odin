package main

import "core:math"

Vector2 :: distinct [2]f32

vec_normalize :: proc(vec: Vector2) -> Vector2 {
	sqr_mag := vec_length_squared(vec)
	if sqr_mag == 0 {
		return {0, 0}
	}

	return vec / math.sqrt(sqr_mag)
}

vec_length :: proc(vec: Vector2) -> f32 {
	return math.sqrt(vec_length_squared(vec))
}

vec_length_squared :: proc(vec: Vector2) -> f32 {
	return vec.x * vec.x + vec.y * vec.y
}

vec_get_radians :: proc(vec: Vector2) -> f32 {
	return math.atan2(vec.y, vec.x)
}
vec_get_degrees :: proc(vec: Vector2) -> f32 {
	return math.to_degrees(vec_get_radians(vec))
}

vec_rotate_by :: proc(vec: Vector2, angle: f32) -> Vector2 {
	rad := math.to_radians(angle)

	new_vec: Vector2

	new_vec.x = math.cos(rad) * vec.x - math.sin(rad) * vec.y
	new_vec.y = math.sin(rad) * vec.x + math.cos(rad) * vec.y

	return new_vec
}

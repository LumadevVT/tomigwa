package main

import "core:fmt"
import "core:math"
import "core:slice"
import "core:time"

bullet_list: [dynamic]Bullet

Bullet :: struct {
	position:        Vector2,
	direction:       Vector2,
	timeout:         f32,
	speed:           f32,
	collider_radius: f32,
	active:          bool,
}

update_bullets :: proc(dt: time.Duration) {
	dt_sec := time.duration_seconds(dt)

	for &bullet in bullet_list {
		if !bullet.active do continue

		if is_off_screen(bullet) {
			bullet.active = false
			// fmt.println("Not on screen anymore!")
			continue
		}

		bullet.position += bullet.direction * bullet.speed * f32(dt_sec)
	}
}

is_off_screen :: proc(bullet: Bullet) -> bool {
	win_dim := get_window_dimensions()

	return(
		bullet.position.x > win_dim.x + 100 ||
		bullet.position.x < -100 ||
		bullet.position.y > win_dim.y + 100 ||
		bullet.position.y < -100 \
	)
}

render_bullets :: proc() {
	for bullet in bullet_list {
		if !bullet.active do continue

		draw_circle(bullet.position, bullet.collider_radius, {RED.r, RED.g, RED.b, 50})
	}
}

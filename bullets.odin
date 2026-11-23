package main

import "core:fmt"
import "core:math"
import "core:slice"
import "core:time"

// Collider :: union {
// 	Rect,
// 	Circle,
// }

Bullet :: struct {
	position:        Vector2,
	direction:       Vector2,
	timeout:         f32,
	speed:           f32,
	collider_radius: f32,
	active:          bool,
}

BulletSpawner :: struct {
	bullets:     [dynamic]Bullet,
	position:    Vector2,
	num_outputs: int,
}

new_bullet_spawner :: proc(position: Vector2, outputs: int) -> (spawner: ^BulletSpawner) {
	spawner = new(BulletSpawner)
	spawner^ = {
		bullets     = make([dynamic]Bullet, 0, 64),
		num_outputs = outputs,
		position    = position,
	}
	return spawner
}

free_bullet_spawner :: proc(spawner: ^^BulletSpawner) {
	delete(spawner^.bullets)
	free(spawner^)
	spawner^ = nil
}

spawn_bullets :: proc(spawner: ^BulletSpawner, speed: f32, direction: Vector2) {
	direction_angle := vec_get_degrees(direction)
	space := 360 / f32(spawner.num_outputs)

	for i in 0 ..< spawner.num_outputs {

		new_bullet := Bullet {
			position        = spawner.position,
			active          = true,
			collider_radius = 10,
			direction       = vec_rotate_by(direction, space * f32(i)),
			speed           = speed,
		}

		any_inactive := false
		for &bullet, index in spawner.bullets {
			if bullet.active do continue

			any_inactive = true
			spawner.bullets[index] = new_bullet
			// fmt.printfln("Reusing bullet nº %v", index + 1)
			break
		}
		if !any_inactive {
			append(&spawner.bullets, new_bullet)
		}
	}
}

update_bullets :: proc(spawner: ^BulletSpawner, dt: time.Duration) {
	dt_sec := time.duration_seconds(dt)

	for &bullet in spawner.bullets {
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

render_bullets :: proc(spawner: ^BulletSpawner) {
	for bullet in spawner.bullets {
		if !bullet.active do continue

		draw_circle(bullet.position, bullet.collider_radius, {RED.r, RED.g, RED.b, 50})
	}
}

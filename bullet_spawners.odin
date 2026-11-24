package main

BulletSpawner :: struct {
	position: Vector2,
}

RingSpawner :: struct {
	using base:  BulletSpawner,
	num_outputs: i32,
}

SpreadSpawner :: struct {
	using base:   BulletSpawner,
	spread_angle: f32,
	num_outputs:  i32,
}

spawn_bullets :: proc {
	spawn_bullets_radial,
	spawn_bullets_spread,
}

spawn_bullets_radial :: proc(spawner: RingSpawner, speed: f32, direction: Vector2) {
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
		for &bullet, index in bullet_list {
			if bullet.active do continue

			any_inactive = true
			bullet_list[index] = new_bullet
			break
		}
		if !any_inactive {
			append(&bullet_list, new_bullet)
		}
	}
}

spawn_bullets_spread :: proc(spawner: SpreadSpawner, speed: f32, direction: Vector2) {
}

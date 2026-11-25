package main

import "base:runtime"
import "core:c"
import "core:fmt"
import "core:log"
import "core:math"
import "core:slice"
import "core:strings"
import "core:time"
import mu "vendor:microui"
import sdl "vendor:sdl3"

Direction :: enum {
	Left,
	Right,
	Up,
	Down,
}

DirectionVectors :: [Direction]Vector2 {
	.Left  = {-1, 0},
	.Right = {1, 0},
	.Up    = {0, -1},
	.Down  = {0, 1},
}

bullet_spawner: RingSpawner
bullet_speed: f32 = 50
spawner_angle: f32 = 0
update_fps := 60

@(fini)
_delete_constant_maps :: proc "contextless" () {
	context = runtime.default_context()
	delete(KEY_MAP)
}

main :: proc() {
	init()
	defer quit()

	frame_watch: time.Stopwatch
	time.stopwatch_start(&frame_watch)

	bullet_spawner = RingSpawner {
		position    = {640, 360},
		num_outputs = 5,
	}

	running := true
	for running {
		// time.stopwatch_stop(&stopwatch)
		frame_time := time.stopwatch_duration(frame_watch)
		time.stopwatch_reset(&frame_watch)
		time.stopwatch_start(&frame_watch)

		@(static) event: sdl.Event
		for sdl.PollEvent(&event) {
			#partial switch event.type {
			case .QUIT:
				running = false
			case .KEY_DOWN:
				on_key_down(event.key.scancode)

				if event.key.scancode in KEY_MAP {
					mu.input_key_down(&global_ctx.mui_ctx, KEY_MAP[event.key.scancode])
				}
			case .KEY_UP:
				on_key_up(event.key.scancode)
				if event.key.scancode in KEY_MAP {
					mu.input_key_up(&global_ctx.mui_ctx, KEY_MAP[event.key.scancode])
				}
			case .MOUSE_BUTTON_DOWN:
				switch event.button.button {
				case sdl.BUTTON_LEFT:
					mu.input_mouse_down(&global_ctx.mui_ctx, i32(event.button.x), i32(event.button.y), .LEFT)
				case sdl.BUTTON_MIDDLE:
					mu.input_mouse_down(&global_ctx.mui_ctx, i32(event.button.x), i32(event.button.y), .MIDDLE)
				case sdl.BUTTON_RIGHT:
					mu.input_mouse_down(&global_ctx.mui_ctx, i32(event.button.x), i32(event.button.y), .RIGHT)
				}

			case .MOUSE_BUTTON_UP:
				switch event.button.button {
				case sdl.BUTTON_LEFT:
					mu.input_mouse_up(&global_ctx.mui_ctx, i32(event.button.x), i32(event.button.y), .LEFT)
				case sdl.BUTTON_MIDDLE:
					mu.input_mouse_up(&global_ctx.mui_ctx, i32(event.button.x), i32(event.button.y), .MIDDLE)
				case sdl.BUTTON_RIGHT:
					mu.input_mouse_up(&global_ctx.mui_ctx, i32(event.button.x), i32(event.button.y), .RIGHT)

				}

			case .MOUSE_MOTION:
				mu.input_mouse_move(&global_ctx.mui_ctx, i32(event.motion.x), i32(event.motion.y))
			case .MOUSE_WHEEL:
				mu.input_scroll(&global_ctx.mui_ctx, event.wheel.integer_x, event.wheel.integer_y)
			}
		}

		update(frame_time)


		FRAME_LIMIT := time.Duration(1_000_000_000 / update_fps)
		@(static) counter := 0.0 * time.Millisecond
		counter += frame_time
		for counter >= FRAME_LIMIT {
			fixed_update(FRAME_LIMIT)
			counter -= FRAME_LIMIT
		}

		clear_canvas(RAYWHITE)

		render(frame_time)

		mu.begin(&global_ctx.mui_ctx)

		render_ui(frame_time)

		mu.end(&global_ctx.mui_ctx)

		present_ui()
		present_canvas()

		free_all(context.temp_allocator)
	}
}

init :: proc() {
	if !sdl.Init({.EVENTS, .VIDEO, .AUDIO}) {
		panic("FUCK!")
	}

	global_ctx.window = sdl.CreateWindow("Tomigwa", 1280, 720, nil)
	if global_ctx.window == nil {
		return
	}

	global_ctx.renderer = sdl.CreateRenderer(global_ctx.window, nil)
	if global_ctx.renderer == nil {
		return
	}

	// sdl.SetRenderVSync(get_renderer(), 1)
	sdl.SetDefaultTextureScaleMode(get_renderer(), .PIXELART)
	sdl.SetRenderDrawBlendMode(get_renderer(), {.BLEND})

	mu.init(&global_ctx.mui_ctx)
	global_ctx.mui_ctx.text_width = text_width
	global_ctx.mui_ctx.text_height = text_height

	init_input()
	bullet_list = make([dynamic]Bullet, 0, 128)
}

quit :: proc() {
	delete(bullet_list)
	shutdown_input()
	sdl.DestroyRenderer(global_ctx.renderer)
	sdl.DestroyWindow(global_ctx.window)
}

update :: proc(dt: time.Duration) {

}

DEFAULT_SPAWN_INTERVAL :: 1000
spawn_interval := DEFAULT_SPAWN_INTERVAL
fixed_update_fps := 0
fixed_update :: proc(dt: time.Duration) {
	@(static) time_counter := 0 * time.Second
	@(static) fixed_update_frame_counter := 0

	time_counter += dt
	fixed_update_frame_counter += 1

	defer if time_counter >= 1 * time.Second {
		time_counter -= 1 * time.Second
		fixed_update_fps = fixed_update_frame_counter
		fixed_update_frame_counter = 0

		log.debugf("FPS: %v", fixed_update_frame_counter)
	}

	@(static) spawn_counter := 0 * time.Second

	spawn_counter += dt
	if spawn_counter >= time.Duration(spawn_interval) * time.Millisecond {
		spawn_bullets(bullet_spawner, f32(bullet_speed), vec_rotate_by(DirectionVectors[.Up], f32(spawner_angle)))
		spawn_counter = 0
	}

	update_bullets(dt)

	direction: Vector2
	SPEED :: 300

	if is_key_down(.W) do direction.y -= 1
	if is_key_down(.S) do direction.y += 1
	if is_key_down(.A) do direction.x -= 1
	if is_key_down(.D) do direction.x += 1

	player.position += vec_normalize(direction) * SPEED * f32(time.duration_seconds(dt))
}

render :: proc(dt: time.Duration) {
	@(static) time_counter := 0 * time.Second
	@(static) render_frame_counter := 0
	@(static) render_fps := 0
	time_counter += dt
	render_frame_counter += 1

	defer if time_counter >= 1 * time.Second {
		time_counter -= 1 * time.Second
		render_fps = render_frame_counter
		render_frame_counter = 0
		active_bullet_count := slice.reduce(
			bullet_list[:],
			0,
			proc(count: int, bullet: Bullet) -> int {return bullet.active ? count + 1 : count},
		)

		log.debugf("Active Bullets: ", active_bullet_count)
	}

	render_bullets()
	draw_rect({player.position.x, player.position.y, player.spite.w, player.spite.h}, PURPLE)

	sdl.RenderDebugTextFormat(get_renderer(), 0, 0, "Frame Time: %.2f ms", time.duration_milliseconds(dt))
	sdl.RenderDebugTextFormat(get_renderer(), 0, 10, "Fixed Update FPS: %i", fixed_update_fps)
	sdl.RenderDebugTextFormat(get_renderer(), 0, 20, "Renderization FPS: %i", render_fps)
}

render_ui :: proc(dt: time.Duration) {
	if mu.begin_window(&global_ctx.mui_ctx, "Spawner and Bullet Parameters", {10, 50, 300, 200}) {
		defer mu.end_window(&global_ctx.mui_ctx)

		mu.slider(&global_ctx.mui_ctx, &spawner_angle, 0, 360, 1)
		mu.slider(&global_ctx.mui_ctx, &bullet_speed, 10, 3000, 1)
		@(static) interval: f32 = DEFAULT_SPAWN_INTERVAL
		mu.slider(&global_ctx.mui_ctx, &interval, 10, 500, 1)
		spawn_interval = int(interval)
	}
}

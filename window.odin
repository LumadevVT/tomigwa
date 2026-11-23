package main

import sdl "vendor:sdl3"
get_window_dimensions :: proc() -> Vector2 {
	w, h: i32
	sdl.GetRenderOutputSize(get_renderer(), &w, &h)

	return {f32(w), f32(h)}
}

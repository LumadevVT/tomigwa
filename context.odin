package main

import mu "vendor:microui"
import sdl "vendor:sdl3"

Window :: sdl.Window
Renderer :: sdl.Renderer

Context :: struct {
	window:   ^Window,
	renderer: ^Renderer,
	mui_ctx:  mu.Context,
}

global_ctx: Context

get_window :: proc() -> ^Window {
	return global_ctx.window
}

get_renderer :: proc() -> ^Renderer {
	return global_ctx.renderer
}

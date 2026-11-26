package main

import "core:c"
import "core:fmt"
import "core:math"
import sdl "vendor:sdl3"

Rect :: sdl.FRect
Circle :: struct {
	position: Vector2,
	radius:   f32,
}

Pivot :: enum {
	TopLeft,
	Top,
	TopRight,
	CenterLeft,
	Center,
	CenterRight,
	BottomLeft,
	Bottom,
	BottomRight,
}

coords_to_pivot :: proc {
	coords_to_pivot_rect,
	coords_to_pivot_circle,
}

coords_to_pivot_circle :: proc(circle: Circle, pivot: Pivot) -> (new_pos: Vector2) {
	switch pivot {
	case .TopLeft:
		new_pos.y = circle.position.y - circle.radius
		new_pos.x = circle.position.x - circle.radius
	case .Top:
		new_pos.y = circle.position.y - circle.radius
		new_pos.x = circle.position.x
	case .TopRight:
		new_pos.y = circle.position.y - circle.radius
		new_pos.x = circle.position.x + circle.radius
	case .CenterLeft:
		new_pos.y = circle.position.y
		new_pos.x = circle.position.x - circle.radius
	case .Center:
		new_pos.y = circle.position.y
		new_pos.x = circle.position.x
	case .CenterRight:
		new_pos.y = circle.position.y
		new_pos.x = circle.position.x + circle.radius
	case .BottomLeft:
		new_pos.y = circle.position.y + circle.radius
		new_pos.x = circle.position.x - circle.radius
	case .Bottom:
		new_pos.y = circle.position.y + circle.radius
		new_pos.x = circle.position.x
	case .BottomRight:
		new_pos.y = circle.position.y + circle.radius
		new_pos.x = circle.position.x + circle.radius
	}
	return new_pos
}

coords_to_pivot_rect :: proc(rect: Rect, pivot: Pivot) -> (new_pos: Vector2) {
	switch pivot {
	case .TopLeft:
		new_pos.y = rect.y
		new_pos.x = rect.x
	case .Top:
		new_pos.y = rect.y
		new_pos.x = rect.x - rect.w / 2.0
	case .TopRight:
		new_pos.y = rect.y
		new_pos.x = rect.x - rect.w
	case .CenterLeft:
		new_pos.y = rect.y - rect.h / 2.0
		new_pos.x = rect.x
	case .Center:
		new_pos.y = rect.y - rect.h / 2.0
		new_pos.x = rect.x - rect.w / 2.0
	case .CenterRight:
		new_pos.y = rect.y - rect.h / 2.0
		new_pos.x = rect.x - rect.w
	case .BottomLeft:
		new_pos.y = rect.y - rect.h
		new_pos.x = rect.x
	case .Bottom:
		new_pos.y = rect.y - rect.h
		new_pos.x = rect.x - rect.w / 2.0
	case .BottomRight:
		new_pos.y = rect.y - rect.h
		new_pos.x = rect.x - rect.w
	}
	return new_pos
}

set_draw_color :: proc(color: Color) {
	sdl.SetRenderDrawColor(get_renderer(), color.r, color.g, color.b, color.a)
}


clear_canvas :: proc(color := BLACK) {
	set_draw_color(color)
	sdl.RenderClear(get_renderer())
}

present_canvas :: proc() {
	sdl.RenderPresent(get_renderer())
}

draw_rect :: draw_rect_filled

draw_rect_lines :: proc(rect: Rect, color: Color) {
	rect := rect
	rect.x -= rect.w / 2.0
	rect.y -= rect.h / 2.0
	set_draw_color(color)
	sdl.RenderRect(get_renderer(), &rect)
}

draw_rect_filled :: proc(rect: Rect, color: Color, pivot := Pivot.Center) {
	rect := rect
	pos := coords_to_pivot(rect, pivot)
	rect.x = pos.x
	rect.y = pos.y
	set_draw_color(color)
	sdl.RenderFillRect(get_renderer(), &rect)
}

draw_circle :: proc(pos: Vector2, radius: f32, color: Color, pivot := Pivot.Center) {
	l := radius * math.cos_f32(math.PI / 4)
	set_draw_color(color)
	for x in 0 ..= l {
		y := math.sqrt(radius * radius - x * x)

		sdl.RenderLine(get_renderer(), pos.x - x, pos.y + y, pos.x + x, pos.y + y)
		sdl.RenderLine(get_renderer(), pos.x - x, pos.y - y, pos.x + x, pos.y - y)
		sdl.RenderLine(get_renderer(), pos.x - y, pos.y + x, pos.x + y, pos.y + x)
		sdl.RenderLine(get_renderer(), pos.x - y, pos.y - x, pos.x + y, pos.y - x)
	}

}

draw_circle_line :: proc(pos: Vector2, radius: f32, color: Color, pivot := Pivot.Center) {
	pivot_pos := coords_to_pivot({pos, radius}, pivot)

	l := radius * math.cos_f32(math.PI / 4)
	set_draw_color(color)
	for x in 0 ..= l {
		y := math.sqrt(radius * radius - x * x)
		sdl.RenderPoint(get_renderer(), pivot_pos.x + x, pivot_pos.y + y)
		sdl.RenderPoint(get_renderer(), pivot_pos.x - x, pivot_pos.y + y)
		sdl.RenderPoint(get_renderer(), pivot_pos.x + x, pivot_pos.y - y)
		sdl.RenderPoint(get_renderer(), pivot_pos.x - x, pivot_pos.y - y)
		sdl.RenderPoint(get_renderer(), pivot_pos.x + y, pivot_pos.y + x)
		sdl.RenderPoint(get_renderer(), pivot_pos.x + y, pivot_pos.y - x)
		sdl.RenderPoint(get_renderer(), pivot_pos.x - y, pivot_pos.y + x)
		sdl.RenderPoint(get_renderer(), pivot_pos.x - y, pivot_pos.y - x)
	}
}

draw_line :: proc(start, end: Vector2, color: Color) {
	set_draw_color(color)
	sdl.RenderLine(get_renderer(), start.x, start.y, end.x, end.y)
}

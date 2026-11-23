#+feature dynamic-literals
package main

import "core:strings"
import mu "vendor:microui"
import sdl "vendor:sdl3"

KEY_MAP := map[sdl.Scancode]mu.Key {
	.LSHIFT    = .SHIFT,
	.RSHIFT    = .SHIFT,
	.LCTRL     = .CTRL,
	.RCTRL     = .CTRL,
	.LALT      = .ALT,
	.RALT      = .ALT,
	.BACKSPACE = .BACKSPACE,
	.DELETE    = .DELETE,
	.RETURN    = .RETURN,
	.LEFT      = .LEFT,
	.RIGHT     = .RIGHT,
	.HOME      = .HOME,
	.END       = .END,
	.A         = .A,
	.X         = .X,
	.C         = .C,
	.V         = .V,
}

text_width :: proc(font: mu.Font, text: string) -> i32 {
	return 8 * i32(len(text))
}
text_height :: proc(font: mu.Font) -> i32 {
	return 8
}

present_ui :: proc() {
	command: ^mu.Command
	for mu.next_command(&global_ctx.mui_ctx, &command) {
		switch cmd in command.variant {
		case ^mu.Command_Jump:
		case ^mu.Command_Clip:
			rect := sdl.Rect{cmd.rect.x, cmd.rect.y, cmd.rect.w, cmd.rect.h}
			sdl.SetRenderClipRect(get_renderer(), &rect)
		case ^mu.Command_Rect:
			rect := Rect{f32(cmd.rect.x), f32(cmd.rect.y), f32(cmd.rect.w), f32(cmd.rect.h)}
			color := Color{cmd.color.r, cmd.color.g, cmd.color.b, cmd.color.a}
			draw_rect(rect, color, .TopLeft)
		case ^mu.Command_Text:
			color := Color{cmd.color.r, cmd.color.g, cmd.color.b, cmd.color.a}
			set_draw_color(color)
			sdl.RenderDebugText(
				get_renderer(),
				f32(cmd.pos.x),
				f32(cmd.pos.y),
				strings.clone_to_cstring(cmd.str, context.temp_allocator),
			)
		case ^mu.Command_Icon:
		}
	}
}

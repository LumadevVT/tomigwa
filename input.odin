package main

import ba "core:container/bit_array"
import sdl "vendor:sdl3"

Key :: sdl.Scancode

KeyStateArray :: ba.Bit_Array

current_key_state: ^KeyStateArray
previous_key_state: ^KeyStateArray

init_input :: proc() {
	current_key_state = ba.create_from_enum(Key)
	previous_key_state = ba.create_from_enum(Key)
}
shutdown_input :: proc() {
	ba.destroy(current_key_state)
	ba.destroy(previous_key_state)
}

update_input :: proc() {
	ba.clear(previous_key_state)
	it := ba.make_iterator(current_key_state)

	for index, ok := ba.iterate_by_set(&it); ok; index, ok = ba.iterate_by_set(&it) {
		ba.set(current_key_state, index)
	}
}

on_key_down :: proc(key: Key) {
	ba.set(current_key_state, int(key))
}

on_key_up :: proc(key: Key) {
	ba.unset(current_key_state, int(key))
}

is_key_pressed :: proc(key: Key) -> bool {
	return ba.get(current_key_state, int(key)) == true && ba.get(previous_key_state, int(key)) == false
}

is_key_down :: proc(key: Key) -> bool {
	return ba.get(current_key_state, int(key))
}

is_key_released :: proc(key: Key) -> bool {
	return ba.get(current_key_state, int(key)) == false && ba.get(previous_key_state, int(key)) == true
}

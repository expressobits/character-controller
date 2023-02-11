extends Node3D

## Base class for demo level.
## Manages mouse inputs and their capture.

## If true, Esc key quit game
@export var fast_close := true


func _ready() -> void:
	if !OS.is_debug_build():
		fast_close = false
	if fast_close:
		print("** Fast Close enabled in the 'level.gd' script **")
		print("** 'Esc' to close 'Shift + F1' to release mouse **")
	set_process_input(fast_close)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit() # Quits the game
	
	if event.is_action_pressed("change_mouse_input"):
		match Input.get_mouse_mode():
			Input.MOUSE_MODE_CAPTURED:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			Input.MOUSE_MODE_VISIBLE:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


# Capture mouse if clicked on the game, needed for HTML5
# Called when an InputEvent hasn't been consumed by _input() or any GUI item
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

extends MovementAbility3D

class_name CrouchAbility3D

signal crouched
signal uncrouched

var _was_crouching := false

@export var crouch_speed_multiplier := 0.7
	
func get_speed_modifier() -> float:
	if is_actived():
		return crouch_speed_multiplier
	else:
		return super.get_speed_modifier()
	
func set_active(a : bool) -> void:
	active = a
	if !_was_crouching and is_actived():
		emit_signal("crouched")
	elif _was_crouching and !is_actived():
		emit_signal("uncrouched")
	_was_crouching = is_actived()

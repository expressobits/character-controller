extends MovementAbility3D

class_name CrouchAbility3D

var _is_crouching := false
var _was_crouching := false

@export var crouch_speed_multiplier := 0.7
	
func get_speed_modifier() -> float:
	if _is_crouching:
		return crouch_speed_multiplier
	else:
		return super.get_speed_modifier()
	
func check_crouch(_delta, input_crouch : bool, disable_crouch : bool, head_is_colliding : bool, is_in_floor : bool):
	_is_crouching = (input_crouch or (head_is_colliding and is_in_floor)) and disable_crouch
	
	if !_was_crouching and is_crouching():
		emit_signal("crouched")
#		_speed_modifiers *= crouch_speed_multiplier
#		_fov_modifiers *= crouch_fov_multiplier
	elif _was_crouching and !is_crouching():
		emit_signal("uncrouched")
#		_speed_modifiers /= crouch_speed_multiplier
#		_fov_modifiers /= crouch_fov_multiplier
	_was_crouching = is_crouching()
	
func is_crouching():
	return _is_crouching

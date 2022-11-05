extends MovementAbility3D

class_name SprintAbility3D

signal sprinted

var _is_sprinting := false
var _was_sprinting := false
@export var sprint_speed_multiplier := 1.6
	
func get_speed_modifier() -> float:
	if _is_sprinting:
		return sprint_speed_multiplier
	else:
		return super.get_speed_modifier()
		
func is_actived() -> bool:
	return _is_sprinting
	
func check_sprint(_delta, is_on_floor : bool, input_sprint: bool, input_axis : Vector2, is_crouching : bool):
	_is_sprinting = is_on_floor and input_sprint and input_axis.x >= 0.5 and !is_crouching
	if !_was_sprinting and is_actived():
		emit_signal("sprinted")
#		_fov_modifiers *= sprint_fov_multiplier
#	if _was_sprinting and !is_actived():
#		_fov_modifiers /= sprint_fov_multiplier
	_was_sprinting = is_actived()

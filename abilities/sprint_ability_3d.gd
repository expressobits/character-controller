extends MovementAbility3D

class_name SprintAbility3D

signal sprinted

var _was_sprinting := false
@export var sprint_speed_multiplier := 1.6
	
func get_speed_modifier() -> float:
	if is_actived():
		return sprint_speed_multiplier
	else:
		return super.get_speed_modifier()
	
func set_active(a : bool) -> void:
	active = a
	if !_was_sprinting and is_actived():
		emit_signal("sprinted")
	_was_sprinting = is_actived()	

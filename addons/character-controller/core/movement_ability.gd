extends Node3D

# Abstract class
class_name MovementAbility3D

@export var active := false
var _last_active := false

signal actived
signal deactived

func get_speed_modifier() -> float:
	return 1.0
	
func is_actived() -> bool:
	return active
	
func set_active(a : bool) -> void:
	_last_active = active
	active = a
	if _last_active != active:
		if active:
			emit_signal("actived")
		else:
			emit_signal("deactived")
	
	
func apply(velocity : Vector3, speed : float, is_on_floor : bool, direction : Vector3, _delta : float) -> Vector3:
	return velocity

extends Node3D

# Abstract class
class_name MovementAbility3D

var active := false

func get_speed_modifier() -> float:
	return 1.0
	
func is_actived() -> bool:
	return active
	
func set_active(a : bool) -> void:
	active = a
	
func apply(velocity : Vector3, speed : float, is_on_floor : bool, direction : Vector3, _delta : float) -> Vector3:
	return velocity

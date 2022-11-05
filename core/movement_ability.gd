extends Node3D

# Abstract class
class_name MovementAbility3D

var active : bool

func get_speed_modifier() -> float:
	return 1.0
	
func is_actived() -> bool:
	return active
	
func set_active(a : bool) -> void:
	active = a

extends MovementAbility3D

class_name CrouchAbility3D

@export var crouch_speed_multiplier := 0.7
	
func get_speed_modifier() -> float:
	if is_actived():
		return crouch_speed_multiplier
	else:
		return super.get_speed_modifier()

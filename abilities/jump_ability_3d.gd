extends MovementAbility3D

class_name JumpAbility3D

signal jumped

@export_group("Jump")
@export var jump_height := 10

func get_speed_modifier() -> float:
	return 1.0
	
func apply(velocity : Vector3, speed : float, is_on_floor : bool, direction : Vector3, _delta : float) -> Vector3:
	if is_actived():
		velocity.y = jump_height
		emit_signal("jumped")
	return velocity

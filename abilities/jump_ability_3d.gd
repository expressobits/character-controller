extends MovementAbility3D

class_name JumpAbility3D

@export_group("Jump")
@export var jump_height := 10
	
func apply(velocity : Vector3, speed : float, is_on_floor : bool, direction : Vector3, _delta : float) -> Vector3:
	if is_actived():
		velocity.y = jump_height
	return velocity

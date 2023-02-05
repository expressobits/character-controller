extends MovementAbility3D
class_name JumpAbility3D

## Simple ability that adds a vertical impulse when actived (Jump)

## Jump/Impulse height
@export var height := 10


## Change vertical velocity of [CharacterController3D]
func apply(velocity : Vector3, speed : float, is_on_floor : bool, direction : Vector3, _delta : float) -> Vector3:
	if is_actived():
		velocity.y = height
	return velocity

extends MovementAbility3D
class_name FlyAbility3D

## Ability that gives free movement to [CharacterController 3D] completely ignoring gravity.

## Speed modifier while this ability is active
@export var speed_modifier := 2.0

## Get actual speed modifier
func get_speed_modifier() -> float:
	if is_actived():
		return speed_modifier
	else:
		return super.get_speed_modifier()

## Apply velocity to [CharacterController3D]
func apply(velocity: Vector3, speed : float, is_on_floor : bool, direction : Vector3, delta: float) -> Vector3:
	if not is_actived():
		return velocity
	velocity = direction * speed
	return velocity

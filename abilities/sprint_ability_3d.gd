extends MovementAbility3D
class_name SprintAbility3D

## Ability that adds extra speed when actived

## Speed to be multiplied when active the ability
@export var speed_multiplier := 1.6

## Returns a speed modifier, 
## useful for abilities that when active can change the overall speed of the [CharacterController3D], for example the [SprintAbility3D].
func get_speed_modifier() -> float:
	if is_actived():
		return speed_multiplier
	else:
		return super.get_speed_modifier()

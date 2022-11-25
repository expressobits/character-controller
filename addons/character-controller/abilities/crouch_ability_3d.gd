extends MovementAbility3D

class_name CrouchAbility3D

@export var speed_multiplier := 0.7
@export var collision : CollisionShape3D
@export var head_check : RayCast3D
@export var height_in_crouch := 1.0
@export var default_height := 2.0
	
func get_speed_modifier() -> float:
	if is_actived():
		return speed_multiplier
	else:
		return super.get_speed_modifier()
		
func apply(velocity: Vector3, speed : float, is_on_floor : bool, direction : Vector3, delta: float) -> Vector3:
	if is_actived():
		collision.shape.height -= delta * 8
	elif not head_check.is_colliding():
		collision.shape.height += delta * 8
	collision.shape.height = clamp(collision.shape.height , height_in_crouch, default_height)
	return velocity

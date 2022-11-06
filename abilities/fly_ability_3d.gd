extends MovementAbility3D

class_name FlyAbility3D

@export var fly_mode_speed_modifier := 2.0
	
func get_speed_modifier() -> float:
	if is_actived():
		return fly_mode_speed_modifier
	else:
		return super.get_speed_modifier()
		
func apply(velocity: Vector3, speed : float, is_on_floor : bool, direction : Vector3, delta: float) -> Vector3:
	if not is_actived():
		return velocity
	velocity = direction * speed
	return velocity

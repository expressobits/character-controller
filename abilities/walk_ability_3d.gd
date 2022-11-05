extends MovementAbility3D

class_name WalkAbility3D

signal sprinted

@export var acceleration := 8
@export var deceleration := 10
	
func accelerate(is_on_floor : bool, air_control : float, speed : float, velocity : Vector3, direction : Vector3, delta: float) -> Vector3:
	if not active:
		return velocity
	
	# Using only the horizontal velocity, interpolate towards the input.
	var temp_vel := velocity
	temp_vel.y = 0
	
	var temp_accel: float
	var target: Vector3 = direction * speed
	
	if direction.dot(temp_vel) > 0:
		temp_accel = acceleration
	else:
		temp_accel = deceleration
	
	if not is_on_floor:
		temp_accel *= air_control
	
	temp_vel = temp_vel.lerp(target, temp_accel * delta)
	
	velocity.x = temp_vel.x
	velocity.z = temp_vel.z
	return velocity

extends MovementAbility3D
class_name ClimbStepAbility3D

## Ability that allows the character to climb up steps/stairs.
## Uses a ShapeCast3D to detect obstacles ahead and applies upward movement when a step is detected.

## Maximum step height that can be climbed
@export var step_size: float = 0.5

## Minimum step height to trigger climbing (ignores very small steps)
@export var min_step_size: float = 0.25

## Distance ahead in movement direction to check for steps (distance from edge to step)
@export var check_distance: float = 0.5

## Reference to the character controller (to access position and collision)
var character_body: CharacterBody3D

## Reference to the character's collision shape (to calculate foot position)
var collision_shape: CollisionShape3D

## Minimum horizontal velocity magnitude to trigger step climbing
@export var min_velocity_threshold: float = 0.01

## Base velocity multiplier for climbing (multiplied by step height)
@export var climb_velocity_multiplier: float = 8.0

## Maximum climb velocity to prevent excessive jumping
@export var max_climb_velocity: float = 15.0

## Apply step climbing logic
func apply(velocity: Vector3, speed: float, is_on_floor: bool, direction: Vector3, delta: float) -> Vector3:
	if not is_actived():
		return velocity
	
	# Allow climbing even when slightly off floor (in case we're already climbing)
	var is_near_floor = is_on_floor or (character_body and character_body.is_on_floor())
	if not is_near_floor and velocity.y <= 0:
		return velocity
	
	# Use input direction instead of velocity direction to detect steps
	# This ensures we can climb even when velocity is low
	var input_direction = direction
	input_direction.y = 0.0
	input_direction = input_direction.normalized()
	
	# Also check current velocity direction as fallback
	var horizontal_velocity = Vector3(velocity.x, 0.0, velocity.z)
	var horizontal_speed = horizontal_velocity.length()
	var move_direction = input_direction
	
	# If we have significant horizontal velocity, use that direction instead
	if horizontal_speed > min_velocity_threshold:
		move_direction = horizontal_velocity.normalized()
	# If no input and no velocity, can't determine direction
	elif input_direction.length() < 0.1:
		return velocity
	
	var step_height = _can_climb_step(move_direction)
	if step_height > 0.0:
		# Calculate climb velocity based on step height
		var base_climb_velocity = step_height * climb_velocity_multiplier
		
		# Ensure we have minimum velocity to overcome gravity and actually climb
		# Need enough velocity to: 1) overcome gravity, 2) gain height equal to step_height
		# Gravity is ~29.4 (9.8 * 3.0 multiplier) per second, so per frame at 60fps is ~0.49
		# We need velocity that can overcome this AND gain the step height
		var min_required_velocity = step_height * 15.0  # Increased minimum to ensure climbing
		var climb_velocity = max(base_climb_velocity, min_required_velocity)
		climb_velocity = min(climb_velocity, max_climb_velocity)
		
		# Apply upward velocity to climb the step
		# IMPORTANT: Always apply velocity when step is detected, regardless of current velocity
		# This ensures we can climb even when stuck or with low momentum
		velocity.y = climb_velocity
		
		# Also ensure we maintain horizontal movement when climbing
		# If horizontal velocity is too low, add some forward push
		if horizontal_speed < min_velocity_threshold:
			var forward_push = move_direction * speed * 0.3  # 30% of normal speed
			velocity.x = forward_push.x
			velocity.z = forward_push.z
	
	return velocity

## Alternative approach: Test if we can move forward, and if blocked, try moving up
func _test_step_climb(move_direction: Vector3, delta: float) -> bool:
	if not character_body:
		return false
	
	# Test if we can move forward horizontally
	var test_velocity = move_direction * check_distance / delta
	var collision = character_body.test_move(character_body.global_transform, test_velocity * delta)
	
	if collision:
		# We're blocked, try moving up and forward
		var test_velocity_up = test_velocity + Vector3(0, step_size * 10.0, 0)
		var collision_up = character_body.test_move(character_body.global_transform, test_velocity_up * delta)
		
		# If we can move up and forward, it's a step we can climb
		return not collision_up
	
	return false

## Checks if a step can be climbed using test_move
## Returns the step height if climbable, or 0.0 if not
func _can_climb_step(move_direction: Vector3) -> float:
	if not character_body:
		return 0.0
	
	# Use test_move to check if we're blocked when trying to move forward
	# This is more reliable than raycasts because it uses the actual collision shape
	var current_transform = character_body.global_transform
	
	# Test 1: Try to move forward horizontally (this should be blocked by the step)
	var forward_movement = move_direction * check_distance
	var has_collision_forward = character_body.test_move(current_transform, forward_movement)
	
	if not has_collision_forward:
		# No collision when moving forward, so no step to climb
		return 0.0
	
	# Test at maximum step size first
	var up_and_forward = forward_movement + Vector3(0, step_size, 0)
	var has_collision_up_forward = character_body.test_move(current_transform, up_and_forward)
	
	if has_collision_up_forward:
		# Even at max height, we're blocked - step is too high or it's a wall
		return 0.0
	
	# Binary search to find minimum height needed (within min_step_size to step_size)
	# Test a few heights to find the actual step height
	var test_heights = [min_step_size, min_step_size * 2.0, step_size * 0.5, step_size]
	var found_height = 0.0
	
	for test_h in test_heights:
		if test_h < min_step_size:
			continue
		
		var test_movement = forward_movement + Vector3(0, test_h, 0)
		var can_move = not character_body.test_move(current_transform, test_movement)
		
		if can_move:
			found_height = test_h
			break
	
	if found_height < min_step_size:
		# Step is too small to bother climbing
		return 0.0
	
	# We can move up and forward, so it's a step we can climb!
	return found_height

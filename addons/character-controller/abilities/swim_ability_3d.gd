extends MovementAbility3D
class_name SwimAbility3D

## swimming ability of [CharacterController3D].
## 
## There are three possible states: 
## - Touching water
## - floating in water
## - Submerged
##
## Note: the [b]actived[/b] and [b]deactived[/b] signals are emitted when it is 
## submerged(active) and surfaced(deactived)

## Emitted when character controller touched water
signal entered_the_water

## Emitted when character controller stopped touching water
signal exit_the_water

## Emitted when we start to float in water
signal started_floating

## Emitted when we stop to float in water
signal stopped_floating

## Minimum height for [CharacterController3D] to be completely submerged in water.
@export var submerged_height := 0.36

## Minimum height for [CharacterController3D] to be float in water.
@export var floating_height := 0.55

## Speed multiplier when floating water
@export var on_water_speed_multiplier := 0.75

## Speed multiplier when submerged water
@export var submerged_speed_multiplier := 0.5

@onready var _raycast: RayCast3D = get_node(NodePath("RayCast3D"))

var _is_on_water := false
var _is_floating := false
var _was_is_on_water := false
var _was_is_floating := false
var _depth_on_water := 0.0

func get_speed_modifier() -> float:
	if is_actived():
		return submerged_speed_multiplier
	elif is_floating():
		return on_water_speed_multiplier
	else:
		return super.get_speed_modifier()
		
func set_active(a : bool) -> void:
	_is_on_water = _raycast.is_colliding()
	
	if _is_on_water:
		_depth_on_water = -_raycast.to_local(_raycast.get_collision_point()).y
	else:
		_depth_on_water = 2.1
		
	super.set_active(get_depth_on_water() < submerged_height and _is_on_water and a)
	_is_floating = get_depth_on_water() < floating_height and _is_on_water and a
	
	if is_on_water() and !_was_is_on_water:
		emit_signal("entered_the_water")
	elif !is_on_water() and _was_is_on_water:
		emit_signal("exit_the_water")
		
	if is_floating() and !_was_is_floating:
		emit_signal("started_floating")
	elif !is_floating() and _was_is_floating:
		emit_signal("stopped_floating")
		
	_was_is_on_water = _is_on_water
	_was_is_floating = _is_floating
	
func apply(velocity: Vector3, speed : float, is_on_floor : bool, direction : Vector3, delta: float) -> Vector3:
	if not is_floating():
		return velocity
	var depth = floating_height - get_depth_on_water()
	velocity = direction * speed
#	if depth < 0.1: && !is_fly_mode():
	if depth < 0.1:
		# Prevent free sea movement from exceeding the water surface
		velocity.y = min(velocity.y,0)
	return velocity


## Returns true if we are touching the water
func is_on_water() -> bool:
	return _is_on_water


## Returns true if we are floating in water
func is_floating() -> bool:
	return _is_floating


## Returns true if we are submerged in water
func is_submerged() -> bool:
	return is_actived()


## Returns the height of the water in [Character Controller 3D].
## 2.1 or more - Above water level
## 2 - If it's touching our feet
## 0 - If we just got submerged
func get_depth_on_water() -> float:
	return _depth_on_water

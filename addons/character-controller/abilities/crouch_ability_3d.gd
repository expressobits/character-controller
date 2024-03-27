extends MovementAbility3D
class_name CrouchAbility3D

## Crouch Ability, change size collider and velocity of [CharacterController3D].

## Speed multiplier when crouch is actived
@export var speed_multiplier := 0.7

## Collider that changes size when in crouch state
@export var collision : CollisionShape3D

## Raycast that checks if it is possible to exit the crouch state
@export var head_check : RayCast3D

## Collider height when crouch actived
@export var height_in_crouch := 1.0

## Collider height when crouch deactived
@export var default_height := 2.0

var crouch_factor : float

## Applies slow if crouch is enabled
func get_speed_modifier() -> float:
	if is_actived():
		return speed_multiplier
	else:
		return super.get_speed_modifier()

## Set collision height 
func apply(velocity: Vector3, speed : float, is_on_floor : bool, direction : Vector3, delta: float) -> Vector3:
	if is_actived():
		collision.shape.height -= delta * 8
	elif not head_check.is_colliding():
		collision.shape.height += delta * 8
	collision.shape.height = clamp(collision.shape.height , height_in_crouch, default_height)
	crouch_factor = (default_height - height_in_crouch) - (collision.shape.height - height_in_crouch)/ (default_height - height_in_crouch)
	return velocity

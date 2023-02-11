extends Node3D
class_name MovementAbility3D

## Movement skill abstract class.
## 
## It contains a flag to enable/disable the movement skill, signals emitted when this flag was modified.

@export var _active := false
var _last_active := false

## Emitted when ability has been active, is called when [b]set_active()[/b] is set to true
signal actived

## Emitted when ability has been deactive, is called when [b]set_active()[/b] is set to false
signal deactived


## Returns a speed modifier, 
## useful for abilities that when active can change the overall speed of the [CharacterController3D], for example the [SprintAbility3D].
func get_speed_modifier() -> float:
	return 1.0


## Returns true if ability is active
func is_actived() -> bool:
	return _active


## Defines whether or not to activate the ability
func set_active(a : bool) -> void:
	_last_active = _active
	_active = a
	if _last_active != _active:
		if _active:
			emit_signal("actived")
		else:
			emit_signal("deactived")


## Change current velocity of [CharacterController3D].
## In this function abilities can change the way the character controller behaves based on speeds and other parameters received.
func apply(velocity : Vector3, speed : float, is_on_floor : bool, direction : Vector3, _delta : float) -> Vector3:
	return velocity

extends Marker3D
class_name HeadMovement3D

## Node that moves the character's head
## To move just call the function [b]rotate_camera[/b]

## Mouse sensitivity of rotation move
@export var mouse_sensitivity := 2.0

## Vertical angle limit of rotation move
@export var vertical_angle_limit := 90.0

## Actual rotation of movement
var actual_rotation := Vector3()

func _ready() -> void:
	actual_rotation.y = get_owner().rotation.y


## Define mouse sensitivity
func set_mouse_sensitivity(sensitivity):
	mouse_sensitivity = sensitivity


## Define vertical angle limit for rotation movement of head
func set_vertical_angle_limit(limit : float):
	vertical_angle_limit = deg_to_rad(limit)


## Rotates the head of the character that contains the camera used by 
## [FPSController3D].
## Vector2 is sent with reference to the input of a mouse as an example
func rotate_camera(mouse_axis : Vector2) -> void:
	# Horizontal mouse look.
	actual_rotation.y -= mouse_axis.x * (mouse_sensitivity/1000)
	# Vertical mouse look.
	actual_rotation.x = clamp(actual_rotation.x - mouse_axis.y * (mouse_sensitivity/1000), -vertical_angle_limit, vertical_angle_limit)
	
	get_owner().rotation.y = actual_rotation.y
	rotation.x = actual_rotation.x

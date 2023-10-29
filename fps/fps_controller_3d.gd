extends CharacterController3D
class_name FPSController3D

## Character Controller 3D specialized in FPS.
##
## Contains camera information:[br]
## - FOV[br]
## - HeadBob[br]
## - Rotation limits[br]
## - Inputs for camera rotation[br]

@export_group("FOV")

## Speed at which the FOV changes
@export var fov_change_speed := 4

## FOV to be multiplied when active the sprint
@export var sprint_fov_multiplier := 1.1

## FOV to be multiplied when active the crouch
@export var crouch_fov_multiplier := 0.95

## FOV to be multiplied when active the swim
@export var swim_fov_multiplier := 1.0


@export_group("Mouse")

## Mouse Sensitivity
@export var mouse_sensitivity := 2.0:
	set(value):
			if head != null:
				head.mouse_sensitivity = value

## Maximum vertical angle the head can aim
@export var vertical_angle_limit := 90.0


@export_group("Head Bob - Steps")

## Enables bob for made steps
@export var step_bob_enabled := true:
	set(value):
		if head_bob != null:
			head_bob.step_bob_enabled = value

## Difference of step bob movement between vertical and horizontal angle
@export var vertical_horizontal_ratio = 2


@export_group("Head Bob - Jump")

## Enables bob for made jumps
@export var jump_bob_enabled := true:
	set(value):
		if head_bob != null:
			head_bob.jump_bob_enabled = value


@export_group("Head Bob - Rotation When Move (Quake Like)")

## Enables camera angle for the direction the character controller moves
@export var rotation_to_move := true:
	set(value):
		if head_bob != null:
			head_bob.rotation_to_move = value

## Speed at which the camera angle moves
@export var speed_rotation := 4.0

## Rotation angle limit per move
@export var angle_limit_for_rotation := 0.1

## [HeadMovement3D] reference, where the rotation of the camera sight is calculated
@onready var head: HeadMovement3D = get_node(NodePath("Head"))

## First Person Camera3D reference
@onready var first_person_camera_reference : Marker3D = get_node(NodePath("Head/FirstPersonCameraReference"))

## Third Person Camera3D reference
@onready var third_person_camera_reference : Marker3D = get_node(NodePath("Head/ThirdPersonCameraReference"))

## HeadBob reference
@onready var head_bob: HeadBob = get_node(NodePath("Head/Head Bob"))


## Configure mouse sensitivity, rotation limit angle and head bob
## After call the base class setup [CharacterController3D].
func setup():
	super.setup()
	head.set_mouse_sensitivity(mouse_sensitivity)
	head.set_vertical_angle_limit(vertical_angle_limit)
	head_bob.step_bob_enabled = step_bob_enabled
	head_bob.jump_bob_enabled = jump_bob_enabled
	head_bob.rotation_to_move = rotation_to_move
	head_bob.speed_rotation = speed_rotation
	head_bob.angle_limit_for_rotation = angle_limit_for_rotation
	head_bob.vertical_horizontal_ratio = vertical_horizontal_ratio
	head_bob.setup_step_bob(step_interval * 2);

## Rotate head based on mouse axis parameter.
## This function call [b]head.rotate_camera()[/b].
func rotate_head(mouse_axis : Vector2) -> void:
	head.rotate_camera(mouse_axis)


## Call to move the character.
## First it is defined what the direction of movement will be, whether it is vertically or not 
## based on whether swim or fly mode is active.
## Afterwards, the [b]move()[/b] of the base class [CharacterMovement3D] is called
## It is then called functions responsible for head bob if necessary.
func move(_delta: float, input_axis := Vector2.ZERO, input_jump := false, input_crouch := false, input_sprint := false, input_swim_down := false, input_swim_up := false):
	if is_fly_mode() or is_floating():
		_direction_base_node = head
	else:
		_direction_base_node = self
	super.move(_delta, input_axis, input_jump, input_crouch, input_sprint, input_swim_down, input_swim_up)
#	TODO Make in exemple this	
#	if not is_fly_mode() and not swim_ability.is_floating() and not swim_ability.is_submerged()
#		camera.set_fov(lerp(camera.fov, normal_fov, _delta * fov_change_speed))
	_check_head_bob(_delta, input_axis)


func _check_head_bob(_delta, input_axis : Vector2):
	head_bob.head_bob_process(_horizontal_velocity, input_axis, is_sprinting(), is_on_floor(), _delta)


func _on_jumped():
	super._on_jumped()
	head_bob.do_bob_jump()
	head_bob.reset_cycles()

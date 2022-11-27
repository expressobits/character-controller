extends CharacterController3D

class_name FPSController3D

var head_path := NodePath("Head")
var camera_path := NodePath("Head/Camera")
var head_bob_path := NodePath("Head/Head Bob")

@export_group("Mouse")
@export var mouse_sensitivity := 2.0
@export var vertical_angle_limit := 90.0

@export_group("Head Bob - Steps")
@export var step_bob_enabled := true
@export var vertical_horizontal_ratio = 2

@export_group("Head Bob - Jump")
@export var jump_bop_enabled := true

@export_group("Head Bob - Rotation When Move (Quake Like)")
@export var rotation_to_move := true
@export var speed_rotation := 4.0
@export var angle_limit_for_rotation := 0.1

@onready var head: HeadMovement = get_node(head_path)
@onready var camera: Camera3D = get_node(camera_path)
@onready var head_bob: HeadBob = get_node(head_bob_path)
@onready var normal_fov: float = camera.fov

func setup():
	super.setup()
	head.set_mouse_sensitivity(mouse_sensitivity)
	head.set_vertical_angle_limit(vertical_angle_limit)
	head_bob.step_bob_enabled = step_bob_enabled
	head_bob.jump_bop_enabled = jump_bop_enabled
	head_bob.rotation_to_move = rotation_to_move
	head_bob.speed_rotation = speed_rotation
	head_bob.angle_limit_for_rotation = angle_limit_for_rotation
	head_bob.vertical_horizontal_ratio = vertical_horizontal_ratio
	head_bob.setup_bob(step_interval * 2);
	
func _check_head_bob(_delta, input_axis : Vector2):
	head_bob.head_bob_process(horizontal_velocity, input_axis, is_sprinting(), is_on_floor(), _delta)
	
func rotate_head(mouse_axis : Vector2) -> void:
	head.rotate_camera(mouse_axis)
	
func move(_delta: float, input_axis := Vector2.ZERO, input_jump := false, input_crouch := false, input_sprint := false, input_swim_down := false, input_swim_up := false):
	if is_fly_mode() or is_floating():
		direction_base_node = head
	else:
		direction_base_node = self
	super.move(_delta, input_axis, input_jump, input_crouch, input_sprint, input_swim_down, input_swim_up)
	if not is_fly_mode() and not swim_ability.is_floating() and not swim_ability.is_submerged():
		camera.set_fov(lerp(camera.fov, normal_fov * _fov_modifiers, _delta * fov_change_speed))
	_check_head_bob(_delta, input_axis)
	
func _on_jumped():
	super._on_jumped()
	head_bob.do_bob_jump()
	head_bob.reset()

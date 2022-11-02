extends CharacterBody3D
class_name CharacterController3D

signal stepped
signal landed
signal jumped
signal crouched
signal uncrouched
signal sprinted
signal fly_mode_actived
signal fly_mode_deactived
signal emerged
signal subemerged

@export_group("Movement")
@export var gravity_multiplier := 3.0
@export var speed := 10
@export var acceleration := 8
@export var deceleration := 10
@export_range(0.0, 1.0, 0.05) var air_control := 0.3
@export var fov_change_speed := 4

@export_group("Sprint")
@export var sprint_speed_multiplier := 1.6
@export var sprint_fov_multiplier := 1.1

@export_group("Jump")
@export var jump_height := 10

@export_group("Footsteps")
@export var step_lengthen = 0.7
@export var step_interval := 6.0

@export_group("Crouch")
@export var height_in_crouch = 1.0
@export var crouch_speed_multiplier := 0.7
@export var crouch_fov_multiplier := 0.95

@export_group("Swim")
@export var on_water_speed_multiplier := 0.9
@export var submerged_speed_multiplier := 0.7
@export var swim_fov_multiplier := 1.0

@export_group("Fly Mode")
@export var fly_mode_speed_modifier := 2.0

var head_path := NodePath("Head")
var camera_path := NodePath("Head/Camera")
var head_bob_path := NodePath("Head/Head Bob")
var collision_path := NodePath("Collision")
var head_check_path := NodePath("Head Check")
var water_check_path := NodePath("Water Check")

var direction := Vector3()
var input_axis := Vector2()
var input_crouch := false
var input_jump := false
var input_sprint := false
var input_fly_mode := false
var step_cycle : float = 0
var next_step : float = 0
var horizontal_velocity
# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
@onready var gravity: float = (ProjectSettings.get_setting("physics/3d/default_gravity") * gravity_multiplier)
@onready var head: Marker3D = get_node(head_path)
@onready var head_bob: HeadBob = get_node(head_bob_path)
@onready var camera: Camera3D = get_node(camera_path)
@onready var collision: CollisionShape3D = get_node(collision_path)
@onready var head_check: RayCast3D = get_node(head_check_path)
@onready var water_check: WaterCheck = get_node(water_check_path)
@onready var normal_speed: int = speed
@onready var normal_fov: float = camera.fov

var _last_is_on_floor := false
var _was_crouching := false
var _was_sprinting := false
var _default_height : float
var _is_crouching := false
var _is_sprinting := false
var _speed_modifiers := 1.0
var _fov_modifiers := 1.0
var _is_fly_mode := false

func _ready():
	head_bob.setup_bob(step_interval * 2);
	_default_height = collision.shape.height
	water_check.submerged.connect(_on_water_check_submerged.bind())
	water_check.emerged.connect(_on_water_check_emerged.bind())
	water_check.started_floating.connect(_on_water_check_started_floating.bind())
	water_check.stop_floating.connect(_on_water_check_stop_floating.bind())
	

func move(_delta: float) -> void:
	_check_fly_mode()
	
	if is_fly_mode():
		var direction = _direction_input(input_axis, head, false)
		velocity = direction * speed
	elif water_check.is_floating():
		var depth = water_check.get_floating_height() - water_check.get_depth_on_water()
		var direction = _direction_input(input_axis, head, false)
		velocity = direction * speed
		if depth < 0.1 && !is_fly_mode():
			# Prevent free sea movement from exceeding the water surface
			velocity.y = min(velocity.y,0)
		# Testing some games, most don't jump when floating under water
		if not water_check.is_submerged() && input_jump:
			velocity.y = jump_height
			head_bob.do_bob_jump()
			head_bob.reset()
	else:
		var direction = _direction_input(input_axis, self, true)
		_check_landed()
		_jump_and_gravity(_delta)
		_accelerate(direction, _delta)
	move_and_slide()
	horizontal_velocity = Vector3(velocity.x, 0.0, velocity.z)
	
	if not is_fly_mode() and not water_check.is_floating() and not water_check.is_submerged():
		_check_step(_delta)
		_check_sprint(_delta)
		camera.set_fov(lerp(camera.fov, normal_fov * _fov_modifiers, _delta * fov_change_speed))
		
	_check_crouch(_delta)
	_check_head_bob(_delta)
		
	speed = normal_speed * _speed_modifiers


func _check_fly_mode():
	if input_fly_mode:
		_is_fly_mode = !is_fly_mode()
		if is_fly_mode():
			emit_signal("fly_mode_actived")
			_speed_modifiers *= fly_mode_speed_modifier
		else:
			emit_signal("fly_mode_deactived")
			_speed_modifiers /= fly_mode_speed_modifier


func _check_landed():
	if is_on_floor() and not _last_is_on_floor:
		emit_signal("landed")
		reset_step()
	_last_is_on_floor = is_on_floor()
	

func _check_step(_delta):
	if is_step(horizontal_velocity.length(), is_on_floor(), _delta):
		_step(is_on_floor())


func _jump_and_gravity(_delta):
	if is_on_floor() and not head_check.is_colliding():
		if input_jump:
			velocity.y = jump_height
			emit_signal("jumped")
			head_bob.do_bob_jump()
			head_bob.reset()
	else:
		velocity.y -= gravity * _delta


func _direction_input(input : Vector2, aim_target : Node3D, horizontal_only : bool) -> Vector3:
	direction = Vector3()
	var aim: Basis = aim_target.get_global_transform().basis
	if input.x >= 0.5:
		direction -= aim.z
	if input.x <= -0.5:
		direction += aim.z
	if input.y <= -0.5:
		direction -= aim.x
	if input.y >= 0.5:
		direction += aim.x
	# NOTE: For free-flying and swimming movements
	if is_fly_mode() or is_floating():
		if input_jump:
			direction.y += 1.0
		elif input_crouch:
			direction.y -= 1.0
			
	if horizontal_only:
		direction.y = 0
	return direction.normalized()


func _check_crouch(_delta):
	_is_crouching = (input_crouch or (head_check.is_colliding() and is_on_floor())) and not is_floating() and not is_submerged() and not is_fly_mode()
	
	if !_was_crouching and is_crouching():
		emit_signal("crouched")
		_speed_modifiers *= crouch_speed_multiplier
		_fov_modifiers *= crouch_fov_multiplier
	elif _was_crouching and !is_crouching():
		emit_signal("uncrouched")
		_speed_modifiers /= crouch_speed_multiplier
		_fov_modifiers /= crouch_fov_multiplier
		
	if is_crouching():
		collision.shape.height = lerp(collision.shape.height, height_in_crouch, _delta * 8)
	else:
		collision.shape.height = lerp(collision.shape.height, _default_height, _delta * 8)
	_was_crouching = is_crouching()
	
	
func _check_sprint(_delta):
	_is_sprinting = is_on_floor() and input_sprint and input_axis.x >= 0.5 and !_is_crouching
	if !_was_sprinting and is_sprinting():
		emit_signal("sprinted")
		_speed_modifiers *= sprint_speed_multiplier
		_fov_modifiers *= sprint_fov_multiplier
	if _was_sprinting and !is_sprinting():
		_speed_modifiers /= sprint_speed_multiplier
		_fov_modifiers /= sprint_fov_multiplier
	_was_sprinting = is_sprinting()
	
	
func _accelerate(direction : Vector3, delta: float) -> void:
	# Using only the horizontal velocity, interpolate towards the input.
	var temp_vel := velocity
	temp_vel.y = 0
	
	var temp_accel: float
	var target: Vector3 = direction * speed
	
	if direction.dot(temp_vel) > 0:
		temp_accel = acceleration
	else:
		temp_accel = deceleration
	
	if not is_on_floor():
		temp_accel *= air_control
	
	temp_vel = temp_vel.lerp(target, temp_accel * delta)
	
	velocity.x = temp_vel.x
	velocity.z = temp_vel.z
	

func _step(is_on_floor:bool) -> bool:
	reset_step()
	if(is_on_floor):
		emit_signal("stepped")
		return true
	return false
	

func _check_head_bob(_delta):
	head_bob.head_bob_process(horizontal_velocity, input_axis, is_sprinting(), is_on_floor(), _delta)
	

func reset_step():
	next_step = step_cycle + step_interval


func is_crouching():
	return _is_crouching


func is_sprinting():
	return _is_sprinting


func is_fly_mode():
	return _is_fly_mode


func get_speed():
	return speed


func is_submerged():
	return water_check.is_submerged()


func is_floating():
	return water_check.is_floating()


func is_step(velocity:float, is_on_floor:bool, _delta:float) -> bool:
	if(abs(velocity) < 0.1):
		return false
	step_cycle = step_cycle + ((velocity + step_lengthen) * _delta)
	if(step_cycle <= next_step):
		return false
	return true


func _on_water_check_emerged():
	emit_signal("emerged")


func _on_water_check_submerged():
	emit_signal("subemerged")


func _on_water_check_started_floating():
	_fov_modifiers *= swim_fov_multiplier
	_speed_modifiers *= submerged_speed_multiplier


func _on_water_check_stop_floating():
	_fov_modifiers /= swim_fov_multiplier
	_speed_modifiers /= submerged_speed_multiplier

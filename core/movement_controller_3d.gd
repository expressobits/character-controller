extends CharacterBody3D
class_name MovementController3D

signal stepped
signal landed
signal jumped
signal crouched
signal uncrouched

@export_group("Movement")
@export var gravity_multiplier := 3.0
@export var speed := 10
@export var acceleration := 8
@export var deceleration := 10
@export_range(0.0, 1.0, 0.05) var air_control := 0.3

@export_group("Sprint")
@export var sprint_speed_multiplier := 1.6
@export var sprint_fov_multiplier := 1.05

@export_group("Jump")
@export var jump_height := 10

@export_group("Footsteps")
@export var step_lengthen = 0.7
@export var step_interval : float = 8

@export_group("Crouch")
@export var height_in_crouch = 0.32
@export var crouch_speed_multiplier := 0.7
@export var crouch_fov_multiplier := 0.95

@export_group("Inputs")
@export var input_back := "move_backward"
@export var input_forward := "move_forward"
@export var input_left := "move_left"
@export var input_right := "move_right"
@export var input_sprint := "move_sprint"
@export var input_jump := "move_jump"
@export var input_crouch := "move_crouch"

var head_path := NodePath("Head")
var camera_path := NodePath("Head/Camera")
var head_bob_path := NodePath("Head/Head Bob")
var collision_path := NodePath("Collision")
var head_check_path := NodePath("Head Bonker")

var direction := Vector3()
var input_axis := Vector2()
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
@onready var normal_speed: int = speed
@onready var normal_fov: float = camera.fov

var _last_is_on_floor := false
var _was_crouching := false
var _default_height : float
var _is_crouched := false

func _ready():
	head_bob.setup_bob(step_interval * 2);
	_default_height = head.position.y
	

# Called every physics tick. 'delta' is constant
func _physics_process(_delta: float) -> void:
	input_axis = Input.get_vector(input_back, input_forward, input_left, input_right)
	
	_direction_input()
	_check_landed()
	_jump_and_gravity(_delta)
	_accelerate(_delta)
	
	move_and_slide()
	horizontal_velocity = Vector3(velocity.x,0.0,velocity.z)
	
	_check_step(_delta)
	_check_crouch(_delta)
	_check_sprint(_delta)
	_check_head_bob(_delta)
	

func _check_landed():
	if is_on_floor() and !_last_is_on_floor:
		emit_signal("landed")
		reset_step()
	_last_is_on_floor = is_on_floor()
	

func _check_step(_delta):
	if is_step(horizontal_velocity.length(), is_on_floor(), _delta):
		_step(is_on_floor())
	

func _jump_and_gravity(_delta):
	if is_on_floor():
		if Input.is_action_just_pressed(input_jump):
			velocity.y = jump_height
			emit_signal("jumped")
			head_bob.do_bob_jump()
			head_bob.reset()
	else:
		velocity.y -= gravity * _delta
	

func _direction_input() -> void:
	direction = Vector3()
	var aim: Basis = get_global_transform().basis
	if input_axis.x >= 0.5:
		direction -= aim.z
	if input_axis.x <= -0.5:
		direction += aim.z
	if input_axis.y <= -0.5:
		direction -= aim.x
	if input_axis.y >= 0.5:
		direction += aim.x
	direction.y = 0
	direction = direction.normalized()

func _check_crouch(_delta):
	_is_crouched = Input.is_action_pressed(input_crouch) or head_check.is_colliding()
	if !_was_crouching and _is_crouched:
		emit_signal("crouched")
	elif _was_crouching and !_is_crouched:
		emit_signal("uncrouched")
	if is_crouch():
		collision.shape.height = 1.0
		head.position.y = lerp(head.position.y, height_in_crouch, _delta * 8)
	else:
		head.position.y = lerp(head.position.y, _default_height, _delta * 8)
		collision.shape.height = 2.0
	_was_crouching = _is_crouched

func _check_sprint(_delta):
	if can_sprint():
		speed = normal_speed * sprint_speed_multiplier
		camera.set_fov(lerp(camera.fov, normal_fov * sprint_fov_multiplier, _delta * 8))
	elif _is_crouched:
		speed = normal_speed * crouch_speed_multiplier
		camera.set_fov(lerp(camera.fov, normal_fov  * crouch_fov_multiplier, _delta * 8))
	else:
		speed = normal_speed
		camera.set_fov(lerp(camera.fov, normal_fov, _delta * 8))
	

func _accelerate(delta: float) -> void:
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
	head_bob.head_bob_process(horizontal_velocity, input_axis, can_sprint(), is_on_floor(), _delta)

func reset_step():
	next_step = step_cycle + step_interval
	

func can_sprint() -> bool:
	return (is_on_floor() and Input.is_action_pressed(input_sprint) 
			and input_axis.x >= 0.5 and !_is_crouched)
			
func is_crouch():
	return _is_crouched	
	
func get_speed():
	return _is_crouched	

func is_step(velocity:float, is_on_floor:bool, _delta:float) -> bool:
	if(abs(velocity) < 0.1):
		return false
	step_cycle = step_cycle + ((velocity + step_lengthen) * _delta)
	if(step_cycle <= next_step):
		return false
	return true

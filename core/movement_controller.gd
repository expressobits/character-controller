extends CharacterBody3D
class_name MovementController

signal stepped
signal landed
signal jumped

@export var gravity_multiplier := 3.0
@export var speed := 10
@export var acceleration := 8
@export var deceleration := 10
@export_range(0.0, 1.0, 0.05) var air_control := 0.3
@export_node_path(Node) var step_path
#@export_node_path(Node) var head_bob_path

@export_group("Inputs")
@export var jump_height := 10
@export var input_back := "move_backward"
@export var input_forward := "move_forward"
@export var input_left := "move_left"
@export var input_right := "move_right"
@export var input_jump := "move_jump"

var direction := Vector3()
var input_axis := Vector2()
# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
@onready var gravity: float = (ProjectSettings.get_setting("physics/3d/default_gravity") 
		* gravity_multiplier)
@onready var step : Step = get_node(step_path)
#@onready var head_bob : HeadBob = get_node(head_bob_path)

var _last_is_on_floor := false

# Called every physics tick. 'delta' is constant
func _physics_process(delta: float) -> void:
	input_axis = Input.get_vector(input_back, input_forward, input_left, input_right)
	
	direction_input()
	
	if is_on_floor() and !_last_is_on_floor:
		emit_signal("landed")
		
	_last_is_on_floor = is_on_floor()
	
	if is_on_floor():
		if Input.is_action_just_pressed(input_jump):
			velocity.y = jump_height
			emit_signal("jumped")
	else:
		velocity.y -= gravity * delta
	
	accelerate(delta)
	
	move_and_slide()
	
	if step.is_step(velocity.length(), is_on_floor(), delta):
		call_step()
		
#	head_bob.head_bob_process(velocity.length(),is_on_floor(), delta)
	
func call_step():
	emit_signal("stepped")

func direction_input() -> void:
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


func accelerate(delta: float) -> void:
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

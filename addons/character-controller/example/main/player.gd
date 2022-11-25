extends FPSController3D
class_name Player

@export var input_back_action_name := "move_backward"
@export var input_forward_action_name := "move_forward"
@export var input_left_action_name := "move_left"
@export var input_right_action_name := "move_right"
@export var input_sprint_action_name := "move_sprint"
@export var input_jump_action_name := "move_jump"
@export var input_crouch_action_name := "move_crouch"
@export var input_fly_mode_action_name := "move_fly_mode"

@export var underwater_env: Environment

func _ready():
	setup()
	emerged.connect(_on_controller_emerged.bind())
	submerged.connect(_on_controller_subemerged.bind())
	
func _physics_process(delta):
	input_axis = Input.get_vector(input_back_action_name, input_forward_action_name, input_left_action_name, input_right_action_name)
	input_crouch = Input.is_action_pressed(input_crouch_action_name)
	input_jump = Input.is_action_just_pressed(input_jump_action_name)
	input_up = Input.is_action_pressed(input_jump_action_name)
	input_sprint = Input.is_action_pressed(input_sprint_action_name)
	if Input.is_action_just_pressed(input_fly_mode_action_name):
		input_fly_mode = !input_fly_mode
	move(delta)
	
func _on_controller_emerged():
	camera.environment = null

func _on_controller_subemerged():
	camera.environment = underwater_env

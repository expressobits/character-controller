extends Node
class_name HeadBob

## HeadBob Effect for [FPSController3D]

## Node that will receive the headbob effect
@export_node_path("Node3D") var head_path : NodePath


@export_group("Step Bob")

## Enables the headbob effect for the steps taken
@export var step_bob_enabled := true

## Maximum range value of headbob
@export var bob_range = Vector2(0.07, 0.07)

## Curve where bob happens
@export var bob_curve : Curve

## Curve Multiplier
@export var curve_multiplier = Vector2(2,2)

## ## Difference of step headbob movement between vertical and horizontal angle
@export var vertical_horizontal_ratio = 2


@export_group("Jump Bob")

## Enables bob for made jumps
@export var jump_bob_enabled := true

## Resource that stores information from bob lerp jump
@export var timed_bob_curve : TimedBobCurve


@export_group("Rotation To Move (Quake Like)")

## Enables camera angle for the direction the character controller moves
@export var rotation_to_move := true

## Speed at which the camera angle moves
@export var speed_rotation := 4.0

## Rotation angle limit per move
@export var angle_limit_for_rotation := 0.1

## Node that will receive the headbob effect
@onready var head: Node3D = get_node(head_path)

## Actual speed of headbob
var speed : float = 0

## Store original position of head for headbob reference
var original_position : Vector3

## Store original rotation of head for headbob reference
var original_rotation : Vector3

## Actual cycle x of step headbob
var cycle_position_x: float = 0

## Actual cycle x of step headbob
var cycle_position_y: float = 0

## Actual interval of step headbob
var step_interval: float = 0


func _ready():
	original_position = head.position
	original_rotation = head.rotation


## Setup bob with bob base interval
func setup_step_bob(step_interval: float):
	self.step_interval = step_interval


## Applies step headbob and rotation headbob (quake style).
func head_bob_process(horizontal_velocity:Vector3, input_axis:Vector2, is_sprint:bool, is_on_floor:bool, _delta:float):
	if timed_bob_curve:
		timed_bob_curve.bob_process(_delta)
	
	var new_position = original_position
	var new_rotation = original_rotation
	if step_bob_enabled:
		var headpos = _do_head_bob(horizontal_velocity.length(), _delta)
		if is_on_floor:
			new_position += headpos
			
	if timed_bob_curve:
		timed_bob_curve.y -= timed_bob_curve.offset
		
	
	if is_sprint:
		input_axis *= 2
	if rotation_to_move:
		new_rotation += _head_bob_rotation(input_axis.x, input_axis.y, _delta)	
	
	head.position = new_position
	head.rotation = new_rotation


## Apply headbob jump
func do_bob_jump():
	if timed_bob_curve:
		timed_bob_curve.do_bob_cycle()


## Resets head bob step cycles
func reset_cycles():
	cycle_position_x = 0
	cycle_position_y = 0


func _head_bob_rotation(x, z, _delta) -> Vector3:
	var target_rotation = Vector3(x * angle_limit_for_rotation, 0.0, -z * angle_limit_for_rotation)
	return lerp(head.rotation, target_rotation, speed_rotation * _delta)


func _do_head_bob(speed: float, delta: float) -> Vector3:
	var x_pos = (bob_curve.sample(cycle_position_x) * curve_multiplier.x * bob_range.x)
	var y_pos = (bob_curve.sample(cycle_position_y) * curve_multiplier.y * bob_range.y)

	var tick_speed = (speed * delta) / step_interval
	cycle_position_x += tick_speed
	cycle_position_y += tick_speed * vertical_horizontal_ratio

	if(cycle_position_x > 1):
		cycle_position_x -= 1
	if(cycle_position_y > 1):
		cycle_position_y -= 1

	return Vector3(x_pos,y_pos,0)

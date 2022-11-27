extends Node

class_name HeadBob

@export_node_path(Camera3D) var head_path := NodePath("../Camera")
@onready var head: Camera3D = get_node(head_path)


@export_group("Step Bob")
@export var step_bob_enabled := true
@export var bob_range = Vector2(0.07, 0.07)
@export var bob_curve : Curve
@export var curve_multiplier = Vector2(2,2)
@export var vertical_horizontal_ratio = 2

@export_group("Jump Bob")
@export var jump_bop_enabled := true
@export var lerp_bob_curve : LerpBobCurve

@export_group("Rotation To Move (Quake Like)")
@export var rotation_to_move := true
@export var speed_rotation := 4.0
@export var angle_limit_for_rotation := 0.1

var speed : float = 0
var original_position : Vector3
var original_rotation : Vector3
var cycle_position_x: float = 0;
var cycle_position_y: float = 0;
var bob_base_interval: float = 0;

func _ready():
	original_position = head.position
	original_rotation = head.rotation
	
func _head_bob_rotation(x, z, _delta) -> Vector3:
	var target_rotation = Vector3(x * angle_limit_for_rotation, 0.0, -z * angle_limit_for_rotation);
	return lerp(head.rotation, target_rotation, speed_rotation * _delta)
	
func _do_head_bob(speed: float, delta: float) -> Vector3:
	var x_pos = (bob_curve.sample(cycle_position_x) * curve_multiplier.x * bob_range.x)
	var y_pos = (bob_curve.sample(cycle_position_y) * curve_multiplier.y * bob_range.y)

	var tick_speed = (speed * delta) / bob_base_interval
	cycle_position_x += tick_speed
	cycle_position_y += tick_speed * vertical_horizontal_ratio

	if(cycle_position_x > 1):
		cycle_position_x -= 1
	if(cycle_position_y > 1):
		cycle_position_y -= 1

	return Vector3(x_pos,y_pos,0)
	
func head_bob_process(horizontal_velocity:Vector3, input_axis:Vector2, is_sprint:bool, is_on_floor:bool, _delta:float):
	if jump_bop_enabled:
		lerp_bob_curve.bob_process(_delta)
	
	var new_position = original_position
	var new_rotation = original_rotation
	if step_bob_enabled:
		var headpos = _do_head_bob(horizontal_velocity.length(), _delta)
		if is_on_floor:
			new_position += headpos
			
	if jump_bop_enabled:
		new_position.y -= lerp_bob_curve.offset
		
	
	if is_sprint:
		input_axis *= 2
	if rotation_to_move:
		new_rotation += _head_bob_rotation(input_axis.x, input_axis.y, _delta)	
	
	head.position = new_position
	head.rotation = new_rotation

func setup_bob(bob_base_interval: float):
	self.bob_base_interval = bob_base_interval

func do_bob_jump():
	if jump_bop_enabled:
		lerp_bob_curve.do_bob_cycle()
	
func reset():
	cycle_position_x = 0
	cycle_position_y = 0

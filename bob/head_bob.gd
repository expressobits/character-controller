extends Node

class_name HeadBob

@export_node_path(Camera3D) var head_path := NodePath("../Camera")
@onready var head: Camera3D = get_node(head_path)
var speed : float = 0
@export var lerp_bob_curve : LerpBobCurve
@export_group("Rotation To Move (Quake Like)")
@export var rotation_to_move := true
@export var speed_rotation := 4.0
@export var angle_limit_for_rotation := 0.1

var original_position

func _ready():
	original_position = head.position
	
func head_bob_process(horizontal_velocity:Vector3, input_axis:Vector2, is_sprint, is_on_floor:bool, _delta:float):
	lerp_bob_curve.bob_process(_delta)
	var headpos = do_head_bob(horizontal_velocity.length(), _delta)
	var new_position = original_position
	if is_on_floor:
		new_position += headpos
	new_position.y -= lerp_bob_curve.offset
	head.position = new_position
	if is_sprint:
		input_axis *= 2
	if rotation_to_move:
		head_bob_rotation(input_axis.x, input_axis.y, _delta)
		
func head_bob_rotation(x, z, _delta):
	var target_rotation = Vector3(x * angle_limit_for_rotation, 0.0, -z * angle_limit_for_rotation);
	head.rotation = lerp(head.rotation, target_rotation, speed_rotation * _delta);

#Lerp bob	
@export var bob_range = Vector2(0.07, 0.07)
@export var bob_curve : Curve
@export var curve_multiplier = Vector2(2,2)

@export var vertical_horizontal_ratio = 2

var cycle_position_x: float = 0;
var cycle_position_y: float = 0;
var bob_base_interval: float = 0;

func setup_bob(bob_base_interval: float):
	self.bob_base_interval = bob_base_interval

func do_bob_jump():
	pass
#	lerp_bob_curve.do_bob_cycle()

func do_head_bob(speed: float, delta: float) -> Vector3: 
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
	
func reset():
	cycle_position_x = 0
	cycle_position_y = 0

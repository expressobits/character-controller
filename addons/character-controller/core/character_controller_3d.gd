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
signal submerged
signal entered_the_water
signal exit_the_water
signal started_floating
signal stopped_floating

@export_group("Movement")
@export var gravity_multiplier := 3.0
@export var speed := 10
@export var fov_change_speed := 4
@export var acceleration := 8
@export var deceleration := 10
@export var air_control := 0.3

@export_group("Sprint")
@export var sprint_fov_multiplier := 1.1
@export var sprint_speed_multiplier := 1.6

@export_group("Footsteps")
@export var step_lengthen := 0.7
@export var step_interval := 6.0

@export_group("Crouch")
@export var height_in_crouch := 1.0
@export var crouch_fov_multiplier := 0.95
@export var crouch_speed_multiplier := 0.7

@export_group("Jump")
@export var jump_height := 10

@export_group("Fly")
@export var fly_mode_speed_modifier := 2

@export_group("Swim")
@export var swim_fov_multiplier := 1.0
@export var submerged_height := 0.36
@export var floating_height := 0.75
@export var on_water_speed_multiplier := 0.75
@export var submerged_speed_multiplier := 0.5

@export_group("Abilities")
@export var abilities_path: Array[NodePath]

var abilities: Array[MovementAbility3D]

func load_nodes(nodePaths: Array) -> Array:
	var nodes := []
	for nodePath in nodePaths:
		var node := get_node(nodePath)
		if node != null:
			nodes.append(node)
	return nodes

var collision_path := NodePath("Collision")
var head_check_path := NodePath("Head Check")
var walk_ability_path := NodePath("Walk Ability 3D")
var crouch_ability_path := NodePath("Crouch Ability 3D")
var sprint_ability_path := NodePath("Sprint Ability 3D")
var jump_ability_path := NodePath("Jump Ability 3D")
var fly_ability_path := NodePath("Fly Ability 3D")
var swim_ability_path := NodePath("Swim Ability 3D")

var direction := Vector3()
var step_cycle : float = 0
var next_step : float = 0
var horizontal_velocity
var direction_base_node : Node3D
# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
@onready var gravity: float = (ProjectSettings.get_setting("physics/3d/default_gravity") * gravity_multiplier)
@onready var collision: CollisionShape3D = get_node(collision_path)
@onready var head_check: RayCast3D = get_node(head_check_path)
@onready var walk_ability: WalkAbility3D = get_node(walk_ability_path)
@onready var crouch_ability: CrouchAbility3D = get_node(crouch_ability_path)
@onready var sprint_ability: SprintAbility3D = get_node(sprint_ability_path)
@onready var jump_ability: JumpAbility3D = get_node(jump_ability_path)
@onready var fly_ability: FlyAbility3D = get_node(fly_ability_path)
@onready var swim_ability: SwimAbility3D = get_node(swim_ability_path)
@onready var normal_speed: int = speed

var _last_is_on_floor := false
var _default_height : float
var _speed_modifiers := 1.0
var _fov_modifiers := 1.0


func setup():
	direction_base_node = self
	abilities = load_nodes(abilities_path)
	_default_height = collision.shape.height
	_connect_signals()
	_start_variables()


func _connect_signals():
	crouch_ability.actived.connect(_on_crouched.bind())
	crouch_ability.deactived.connect(_on_uncrouched.bind())
	sprint_ability.actived.connect(_on_sprinted.bind())
	jump_ability.actived.connect(_on_jumped.bind())
	fly_ability.actived.connect(_on_fly_mode_actived.bind())
	fly_ability.deactived.connect(_on_fly_mode_deactived.bind())
	swim_ability.actived.connect(_on_swim_ability_submerged.bind())
	swim_ability.deactived.connect(_on_swim_ability_emerged.bind())
	swim_ability.started_floating.connect(_on_swim_ability_started_floating.bind())
	swim_ability.stopped_floating.connect(_on_swim_ability_stopped_floating.bind())
	swim_ability.entered_the_water.connect(_on_swim_ability_entered_the_water.bind())
	swim_ability.exit_the_water.connect(_on_swim_ability_exit_the_water.bind())


func _start_variables():
	walk_ability.acceleration = acceleration
	walk_ability.deceleration = deceleration
	walk_ability.air_control = air_control
	sprint_ability.speed_multiplier = sprint_speed_multiplier
	crouch_ability.speed_multiplier = crouch_speed_multiplier
	crouch_ability.default_height = _default_height
	crouch_ability.height_in_crouch = height_in_crouch
	crouch_ability.collision = collision
	crouch_ability.head_check = head_check
	jump_ability.height = jump_height
	fly_ability.speed_modifier = fly_mode_speed_modifier
	swim_ability.submerged_height = submerged_height
	swim_ability.floating_height = floating_height
	swim_ability.on_water_speed_multiplier = on_water_speed_multiplier
	swim_ability.submerged_speed_multiplier = submerged_speed_multiplier


func move(_delta: float, input_axis := Vector2.ZERO, input_jump := false, input_crouch := false, input_sprint := false, input_swim_down := false, input_swim_up := false) -> void:
	var direction = _direction_input(input_axis, input_swim_down, input_swim_up, direction_base_node)
	if not swim_ability.is_floating():
		_check_landed()
	if not jump_ability.is_actived() and not is_fly_mode() and not is_submerged() and not is_floating():
		velocity.y -= gravity * _delta
	
	swim_ability.set_active(!fly_ability.is_actived())
	jump_ability.set_active(input_jump and is_on_floor() and not head_check.is_colliding())
	walk_ability.set_active(not is_fly_mode() and not swim_ability.is_floating())
	crouch_ability.set_active(input_crouch and is_on_floor() and not is_floating() and not is_submerged() and not is_fly_mode())
	sprint_ability.set_active(input_sprint and is_on_floor() and  input_axis.x >= 0.5 and !is_crouching() and not is_fly_mode() and not swim_ability.is_floating() and not swim_ability.is_submerged())
	
	var multiplier = 1.0
	for ability in abilities:
		multiplier *= ability.get_speed_modifier()
	speed = normal_speed * _speed_modifiers * multiplier
	
	for ability in abilities:
		velocity = ability.apply(velocity, speed, is_on_floor(), direction, _delta)
	
	move_and_slide()
	horizontal_velocity = Vector3(velocity.x, 0.0, velocity.z)
	
	if not is_fly_mode() and not swim_ability.is_floating() and not swim_ability.is_submerged():
		_check_step(_delta)


func _check_landed():
	if is_on_floor() and not _last_is_on_floor:
		emit_signal("landed")
		reset_step()
	_last_is_on_floor = is_on_floor()
	

func _check_step(_delta):
	if is_step(horizontal_velocity.length(), is_on_floor(), _delta):
		_step(is_on_floor())


func _direction_input(input : Vector2, input_down : bool, input_up : bool, aim_node : Node3D) -> Vector3:
	direction = Vector3()
	var aim = aim_node.get_global_transform().basis
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
		if input_up:
			direction.y += 1.0
		elif input_down:
			direction.y -= 1.0
	else:
		direction.y = 0	
	return direction.normalized()


func _step(is_on_floor:bool) -> bool:
	reset_step()
	if(is_on_floor):
		emit_signal("stepped")
		return true
	return false


func reset_step():
	next_step = step_cycle + step_interval


func is_crouching():
	return crouch_ability.is_actived()


func is_sprinting():
	return sprint_ability.is_actived()


func is_fly_mode():
	return fly_ability.is_actived()


func get_speed():
	return speed
	

func is_on_water():
	return swim_ability.is_on_water()


func is_submerged():
	return swim_ability.is_submerged()


func is_floating():
	return swim_ability.is_floating()


func is_step(velocity:float, is_on_floor:bool, _delta:float) -> bool:
	if(abs(velocity) < 0.1):
		return false
	step_cycle = step_cycle + ((velocity + step_lengthen) * _delta)
	if(step_cycle <= next_step):
		return false
	return true

# Bubbly signals
func _on_fly_mode_actived():
	emit_signal("fly_mode_actived")


func _on_fly_mode_deactived():
	emit_signal("fly_mode_deactived")


func _on_crouched():
	emit_signal("crouched")


func _on_uncrouched():
	emit_signal("uncrouched")


func _on_sprinted():
	emit_signal("sprinted")


func _on_jumped():
	emit_signal("jumped")


func _on_swim_ability_emerged():
	emit_signal("emerged")


func _on_swim_ability_submerged():
	emit_signal("submerged")


func _on_swim_ability_entered_the_water():
	emit_signal("entered_the_water")


func _on_swim_ability_exit_the_water():
	emit_signal("exit_the_water")


func _on_swim_ability_started_floating():
	emit_signal("started_floating")


func _on_swim_ability_stopped_floating():
	emit_signal("stopped_floating")

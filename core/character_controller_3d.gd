extends CharacterBody3D
class_name CharacterController3D

## Main class of the addon, contains abilities array for character movements.

## Emitted when the character controller performs a step, called at the end of 
## the [b]move()[/b] 
## function when a move accumulator for a step has ended.
signal stepped

## Emitted when touching the ground after being airborne, called in the 
## [b]move()[/b] function.
signal landed

## Emitted when a jump is processed, is called when [JumpAbility3D] is active.
signal jumped

## Emitted when a crouch is started, is called when [CrouchAbility3D] is active.
signal crouched

## Emitted when a crouch is finished, is called when [CrouchAbility3D] is 
## deactive.
signal uncrouched

## Emitted when a sprint started, is called when [SprintAbility3D] is active.
signal sprinted

## Emitted when a fly mode is started, called when [FlyModeAbility3D] is active.
signal fly_mode_actived

## Emitted when a fly mode is finished, called when [FlyModeAbility3D] is 
## deactive.
signal fly_mode_deactived

## Emitted when emerged in water.
## Called when the height of the water depth returned from the 
## [b]get_depth_on_water()[/b] function of [SwimAbility3D] is greater than the 
## minimum height defined in [b]submerged_height[/b].
signal emerged

## Emitted when submerged in water.
## Called when the water depth height returned from the 
## [b]get_depth_on_water()[/b] function of [SwimAbility3D] is less than the 
## minimum height defined in [b]submerged_height[/b].
signal submerged

## Emitted when it starts to touch the water.
signal entered_the_water

## Emitted when it stops touching the water.
signal exit_the_water

## Emitted when water starts to float.
## Called when the height of the water depth returned from the 
## [b]get_depth_on_water()[/b] function of [SwimAbility3D] is greater than the 
## minimum height defined in [b]floating_height[/b].
signal started_floating

## Emitted when water stops floating.
## Called when the water depth height returned from the 
## [b]get_depth_on_water()[/b] function of [SwimAbility3D] is less than the 
## minimum height defined in [b]floating_height[/b].
signal stopped_floating


@export_group("Movement")

## Controller Gravity Multiplier
## The higher the number, the faster the controller will fall to the ground and 
## your jump will be shorter.
@export var gravity_multiplier : float = 3.0

## Controller base speed
## Note: this speed is used as a basis for abilities to multiply their 
## respective values, changing it will have consequences on [b]all abilities[/b]
## that use velocity.
@export var speed : float = 10.0

## Time for the character to reach full speed
@export var acceleration : float = 8.0

## Time for the character to stop walking
@export var deceleration : float = 10.0

## Sets control in the air
@export var air_control : float = 0.3


@export_group("Sprint")

## Speed to be multiplied when active the ability
@export var sprint_speed_multiplier : float = 1.6


@export_group("Footsteps")

## Maximum counter value to be computed one step
@export var step_lengthen : float = 0.7

## Value to be added to compute a step, each frame that the character is walking this value 
## is added to a counter
@export var step_interval : float = 6.0


@export_group("Crouch")

## Collider height when crouch actived
@export var height_in_crouch : float = 1.0

## Speed multiplier when crouch is actived
@export var crouch_speed_multiplier : float = 0.7


@export_group("Jump")

## Jump/Impulse height
@export var jump_height : float = 10.0


@export_group("Fly")

## Speed multiplier when fly mode is actived
@export var fly_mode_speed_modifier : float = 2.0


@export_group("Swim")

## Minimum height for [CharacterController3D] to be completely submerged in water.
@export var submerged_height : float = 0.36

## Minimum height for [CharacterController3D] to be float in water.
@export var floating_height : float = 0.75

## Speed multiplier when floating water
@export var on_water_speed_multiplier : float = 0.75

## Speed multiplier when submerged water
@export var submerged_speed_multiplier : float = 0.5


@export_group("Abilities")
## List of movement skills to be used in processing this class.
@export var abilities_path: Array[NodePath]

## List of movement skills to be used in processing this class.
var _abilities: Array[MovementAbility3D]
 
## Result direction of inputs sent to [b]move()[/b].
var _direction := Vector3()

## Current counter used to calculate next step.
var _step_cycle : float = 0

## Maximum value for _step_cycle to compute a step.
var _next_step : float = 0

## Character controller horizontal speed.
var _horizontal_velocity : Vector3

## Base transform node to direct player movement
## Used to differentiate fly mode/swim moves from regular character movement.
var _direction_base_node : Node3D

## Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
@onready var gravity: float = (ProjectSettings.get_setting("physics/3d/default_gravity") * gravity_multiplier)

## Collision of character controller.
@onready var collision: CollisionShape3D = get_node(NodePath("Collision"))

## Above head collision checker, used for crouching and jumping.
@onready var head_check: RayCast3D = get_node(NodePath("Head Check"))

## Basic movement ability.
@onready var walk_ability: WalkAbility3D = get_node(NodePath("Walk Ability 3D"))

## Crouch Ability, change size collider and velocity.
@onready var crouch_ability: CrouchAbility3D = get_node(NodePath("Crouch Ability 3D"))

## Ability that adds extra speed when actived.
@onready var sprint_ability: SprintAbility3D = get_node(NodePath("Sprint Ability 3D"))

## Simple ability that adds a vertical impulse when actived (Jump).
@onready var jump_ability: JumpAbility3D = get_node(NodePath("Jump Ability 3D"))

## Ability that gives free movement completely ignoring gravity.
@onready var fly_ability: FlyAbility3D = get_node(NodePath("Fly Ability 3D"))

## Swimming ability.
@onready var swim_ability: SwimAbility3D = get_node(NodePath("Swim Ability 3D"))

## Stores normal speed
@onready var _normal_speed : float = speed

## True if in the last frame it was on the ground
var _last_is_on_floor := false

## Default controller height, affects collider
var _default_height : float


## Loads all character controller skills and sets necessary variables
func setup():
	_direction_base_node = self
	_abilities = _load_nodes(abilities_path)
	_default_height = collision.shape.height
	_connect_signals()
	_start_variables()


## Moves the character controller.
## parameters are inputs that are sent to be handled by all abilities.
func move(_delta: float, input_axis := Vector2.ZERO, input_jump := false, input_crouch := false, input_sprint := false, input_swim_down := false, input_swim_up := false) -> void:
	var direction = _direction_input(input_axis, input_swim_down, input_swim_up, _direction_base_node)
	if not swim_ability.is_floating():
		_check_landed()
	if not jump_ability.is_actived() and not is_fly_mode() and not is_submerged() and not is_floating():
		velocity.y -= gravity * _delta
	
	swim_ability.set_active(!fly_ability.is_actived())
	jump_ability.set_active(input_jump and is_on_floor() and not head_check.is_colliding())
	walk_ability.set_active(not is_fly_mode() and not swim_ability.is_floating())
	crouch_ability.set_active(input_crouch and is_on_floor() and not is_floating() and not is_submerged() and not is_fly_mode())
	sprint_ability.set_active(input_sprint and is_on_floor() and  input_axis.y >= 0.5 and !is_crouching() and not is_fly_mode() and not swim_ability.is_floating() and not swim_ability.is_submerged())
	
	var multiplier = 1.0
	for ability in _abilities:
		multiplier *= ability.get_speed_modifier()
	speed = _normal_speed * multiplier
	
	for ability in _abilities:
		velocity = ability.apply(velocity, speed, is_on_floor(), direction, _delta)
	
	move_and_slide()
	_horizontal_velocity = Vector3(velocity.x, 0.0, velocity.z)
	
	if not is_fly_mode() and not swim_ability.is_floating() and not swim_ability.is_submerged():
		_check_step(_delta)


## Returns true if the character controller is crouched
func is_crouching() -> bool:
	return crouch_ability.is_actived()


## Returns true if the character controller is sprinting
func is_sprinting() -> bool:
	return sprint_ability.is_actived()


## Returns true if the character controller is in fly mode active
func is_fly_mode() -> bool:
	return fly_ability.is_actived()


## Returns the speed of character controller
func get_speed() -> float:
	return speed


## Returns true if the character controller is in water
func is_on_water() -> bool:
	return swim_ability.is_on_water()


## Returns true if the character controller is floating in water
func is_floating() -> bool:
	return swim_ability.is_floating()


## Returns true if the character controller is submerged in water
func is_submerged() -> bool:
	return swim_ability.is_submerged()


func _reset_step():
	_next_step = _step_cycle + step_interval


func _load_nodes(nodePaths: Array) -> Array[MovementAbility3D]:
	var nodes : Array[MovementAbility3D]
	for nodePath in nodePaths:
		var node := get_node(nodePath)
		if node != null:
			var ability = node as MovementAbility3D
			nodes.append(ability)
	return nodes


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


func _check_landed():
	if is_on_floor() and not _last_is_on_floor:
		_on_landed()
		_reset_step()
	_last_is_on_floor = is_on_floor()
	

func _check_step(_delta):
	if _is_step(_horizontal_velocity.length(), is_on_floor(), _delta):
		_step(is_on_floor())


func _direction_input(input : Vector2, input_down : bool, input_up : bool, aim_node : Node3D) -> Vector3:
	_direction = Vector3()
	var aim = aim_node.get_global_transform().basis
	if input.y >= 0.5:
		_direction -= aim.z
	if input.y <= -0.5:
		_direction += aim.z
	if input.x <= -0.5:
		_direction -= aim.x
	if input.x >= 0.5:
		_direction += aim.x
	# NOTE: For free-flying and swimming movements
	if is_fly_mode() or is_floating():
		if input_up:
			_direction.y += 1.0
		elif input_down:
			_direction.y -= 1.0
	else:
		_direction.y = 0	
	return _direction.normalized()


func _step(is_on_floor:bool) -> bool:
	_reset_step()
	if(is_on_floor):
		emit_signal("stepped")
		return true
	return false


func _is_step(velocity:float, is_on_floor:bool, _delta:float) -> bool:
	if(abs(velocity) < 0.1):
		return false
	_step_cycle = _step_cycle + ((velocity + step_lengthen) * _delta)
	if(_step_cycle <= _next_step):
		return false
	return true


# Bubbly signals 😒
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


func _on_landed():
	emit_signal("landed")


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

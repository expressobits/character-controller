extends MovementAbility3D
class_name CrouchJumpBoostAbility3D

## Ability that boosts jump height when crouch and jump are performed in quick succession.
## The player can crouch before jumping or jump before crouching, but both actions
## must happen within a short time window (combo_window).

## Whether this ability is enabled
@export var enabled: bool = true

## Jump height multiplier when crouch+jump combo is detected
@export var jump_boost: float = 1.5

## Time window (in seconds) to perform both actions for the combo
@export var combo_window: float = 1.0

## Reference to the jump ability to monitor jump events
var _jump_ability: JumpAbility3D

## Reference to the crouch ability to monitor crouch events
var _crouch_ability: CrouchAbility3D

## Timestamp of when jump was activated
var _jump_time: float = -1.0

## Timestamp of when crouch was activated
var _crouch_time: float = -1.0

## Whether boost has been applied for current jump (prevents cumulative boosts)
var _boost_applied: bool = false

## Whether player was on floor in previous frame
var _was_on_floor: bool = true

## Initialize references (called from character controller)
func setup(jump_ability_ref: JumpAbility3D, crouch_ability_ref: CrouchAbility3D) -> void:
	_jump_ability = jump_ability_ref
	_crouch_ability = crouch_ability_ref

## Apply jump boost if combo is detected
func apply(velocity: Vector3, speed: float, is_on_floor: bool, direction: Vector3, delta: float) -> Vector3:
	if not enabled:
		return velocity
	
	# Reset boost flag when landing
	if is_on_floor and not _was_on_floor:
		_boost_applied = false
		_jump_time = -1.0
		_crouch_time = -1.0
	
	_was_on_floor = is_on_floor
	
	# Check for combo and apply boost (only once per jump, when ascending)
	if not _boost_applied and not is_on_floor and velocity.y > 0:
		if _check_combo():
			velocity.y *= jump_boost
			_boost_applied = true
	
	return velocity

## Checks if crouch+jump combo happened
## Returns true if combo conditions are met
func _check_combo() -> bool:
	if _jump_time < 0 or _crouch_time < 0:
		return false
	
	var time_diff = abs(_jump_time - _crouch_time)
	return time_diff <= combo_window

## Called when jump signal is emitted (from character controller)
func on_jumped() -> void:
	if not enabled:
		return
	_jump_time = Time.get_ticks_msec() / 1000.0
	# Check if crouch already happened within window
	if _crouch_time >= 0:
		var time_diff = abs(_jump_time - _crouch_time)
		if time_diff <= combo_window:
			# Combo detected, will be applied in apply() when velocity.y > 0
			pass

## Called when crouch signal is emitted (from character controller)
func on_crouched() -> void:
	if not enabled:
		return
	_crouch_time = Time.get_ticks_msec() / 1000.0
	# Check if jump already happened within window
	if _jump_time >= 0:
		var time_diff = abs(_jump_time - _crouch_time)
		if time_diff <= combo_window:
			# Combo detected, will be applied in apply() when velocity.y > 0
			pass

## Called when landed signal is emitted (from character controller)
func on_landed() -> void:
	_boost_applied = false
	_jump_time = -1.0
	_crouch_time = -1.0

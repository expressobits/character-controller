extends RayCast3D

class_name WaterCheck

signal entered_the_water
signal exit_the_water
signal started_floating
signal stop_floating
signal submerged
signal emerged

@export var submerged_height := 0.36
@export var floating_height := 0.55

var _is_on_water := false
var _is_floating_in_water := false
var _is_submerged := false
var _was_is_on_water := false
var _was_is_floating_in_water := false
var _was_is_submerged := false
var _depth_on_water := 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_is_on_water = is_colliding()
	if _is_on_water:
		_depth_on_water = -to_local(get_collision_point()).y
		_is_submerged = get_depth_on_water() < submerged_height
		_is_floating_in_water = get_depth_on_water() < floating_height
	else:
		_is_submerged = false
		_is_floating_in_water = false
		_depth_on_water = 2.1
		
	if is_on_water() and !_was_is_on_water:
		emit_signal("entered_the_water")
	elif !is_on_water() and _was_is_on_water:
		emit_signal("exit_the_water")
		
	if is_floating() and !_was_is_floating_in_water:
		emit_signal("started_floating")
	elif !is_floating() and _was_is_floating_in_water:
		emit_signal("stop_floating")
		
	if is_submerged() and !_was_is_submerged:
		emit_signal("submerged")
	elif !is_submerged() and _was_is_submerged:
		emit_signal("emerged")
		
	_was_is_on_water = _is_on_water
	_was_is_floating_in_water = _is_floating_in_water
	_was_is_submerged = _is_submerged


func is_on_water() -> bool:
	return _is_on_water


func is_submerged() -> bool:
	return _is_submerged


func is_floating() -> bool:
	return _is_floating_in_water
	
func get_floating_height() -> float:
	return floating_height


func get_depth_on_water() -> float:
	return _depth_on_water


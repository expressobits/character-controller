extends RayCast3D

class_name WaterCheck

signal entered_the_water
signal exit_the_water
signal submerged
signal emerged

@export var submerged_height := -0.36

var _is_on_water := false
var _is_submerged := false
var _was_is_on_water := false
var _was_is_submerged := false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_is_on_water = is_colliding()
	if _is_on_water:
		var local_height = to_local(get_collision_point()).y
		_is_submerged = local_height > submerged_height
	else:
		_is_submerged = false
		
	if is_on_water() and !_was_is_on_water:
		emit_signal("entered_the_water")
	elif !is_on_water() and _was_is_on_water:
		emit_signal("exit_the_water")
		
	if is_submerged() and !_was_is_submerged:
		emit_signal("submerged")
	elif !is_submerged() and _was_is_submerged:
		emit_signal("emerged")
		
	_was_is_on_water = _is_on_water
	_was_is_submerged = _is_submerged


func is_on_water() -> bool:
	return _is_on_water


func is_submerged() -> bool:
	return _is_submerged




func _on_exit_the_water():
	pass # Replace with function body.

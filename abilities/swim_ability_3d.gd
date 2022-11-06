extends MovementAbility3D

class_name SwimAbility3D

signal entered_the_water
signal exit_the_water
signal started_floating
signal stopped_floating

@export var submerged_height := 0.36
@export var floating_height := 0.55
@export var on_water_speed_multiplier := 0.75
@export var submerged_speed_multiplier := 0.5
var raycast_path := NodePath("RayCast3D")
@onready var raycast: RayCast3D = get_node(raycast_path)

var _is_on_water := false
var _is_floating := false
var _was_is_on_water := false
var _was_is_floating := false
var _depth_on_water := 0.0

func get_speed_modifier() -> float:
	if is_actived():
		return submerged_speed_multiplier
	elif is_floating():
		return on_water_speed_multiplier
	else:
		return super.get_speed_modifier()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_is_on_water = raycast.is_colliding()
	
	if _is_on_water:
		_depth_on_water = -raycast.to_local(raycast.get_collision_point()).y
	else:
		_depth_on_water = 2.1
		
	set_active(get_depth_on_water() < submerged_height and _is_on_water)
	_is_floating = get_depth_on_water() < floating_height and _is_on_water
	
	if is_on_water() and !_was_is_on_water:
		emit_signal("entered_the_water")
	elif !is_on_water() and _was_is_on_water:
		emit_signal("exit_the_water")
		
	if is_floating() and !_was_is_floating:
		emit_signal("started_floating")
	elif !is_floating() and _was_is_floating:
		emit_signal("stopped_floating")
		
	_was_is_on_water = _is_on_water
	_was_is_floating = _is_floating


func is_on_water() -> bool:
	return _is_on_water


func is_floating() -> bool:
	return _is_floating


func is_submerged() -> bool:
	return is_actived()


func get_floating_height() -> float:
	return floating_height


func get_depth_on_water() -> float:
	return _depth_on_water


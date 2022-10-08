extends Node

class_name Step

signal stepped

@export var step_lengthen = 0.7
@export var interval : float = 8
@export var isStepActive = true

var step_cycle : float = 0
var next_step : float = 0

func is_step(velocity:float, is_on_floor:bool, _delta:float) -> bool:
	if(velocity == 0):
		return false
	step_cycle = step_cycle + ((velocity + step_lengthen) * _delta)
	if(step_cycle <= next_step):
		return false
	return _step(is_on_floor)
	
func _step(is_on_floor:bool) -> bool:
	reset_step()
	if(is_on_floor):
		emit_signal("stepped")
		return true
	return false
		
func reset_step():
	next_step = step_cycle + interval
	

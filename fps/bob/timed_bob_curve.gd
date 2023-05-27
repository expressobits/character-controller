extends Resource
class_name TimedBobCurve

## Timed Bob Curve.
## Used by [HeadMovement] for a jump bob.

## Duration of the entire bob process
@export var duration := 0.2

## Max amount in bob offset
@export var amount := 0.1

## Actual offset of bob
var _offset = 0.0

## Actual direction flag of bob
## true if initial state
## false for final state
var _direction = true

## Current time for current direction flag
var _time = duration

## Return actual offset of bob
func get_offset() -> float:
	return _offset


## Init bob timer
func do_bob_cycle():
	_time = duration
	_direction = false


## Tick process of bob timer
func bob_process(delta):
	if(_time > 0):
		print("sdas")
		_time -= delta
		if(_direction):
			_offset = lerp(0.0, amount, _time/_direction)
		else:
			_offset = lerp(amount, 0.0, _time/_direction)
		if(_time < 0 && !_direction):
			_back_do_bob_cycle()


func _back_do_bob_cycle():
	_time = duration
	_direction = true

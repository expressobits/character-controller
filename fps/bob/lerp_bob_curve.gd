extends Resource

class_name LerpBobCurve

@export var duration := 0.2
@export var amount := 0.1

var offset = 0.0
var direction = true
var time = duration

func get_offset() -> float:
	return offset
	
func bob_process(delta):
	if(time > 0):
		time -= delta
		if(direction):
			offset = lerp(0.0, amount, time/duration)
		else:
			offset = lerp(amount, 0.0, time/duration)
		if(time < 0 && !direction):
			_back_do_bob_cycle()
	
func do_bob_cycle():
	time = duration
	direction = false

func _back_do_bob_cycle():
	time = duration
	direction = true

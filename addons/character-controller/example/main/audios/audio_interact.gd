extends Resource

class_name AudioInteract

@export var jump_audio : AudioStream
@export var landed_audio : AudioStream
@export var step_audios: Array[AudioStream]

func random_step() -> AudioStream:
	return step_audios[randi() % step_audios.size()]

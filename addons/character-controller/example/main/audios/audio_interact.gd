extends Resource
class_name AudioInteract

## Resource that stores data by controller actions.

## Jump Audio
@export var jump_audio : AudioStream

## Landed Audio
@export var landed_audio : AudioStream

## Step Audios
@export var step_audios: Array[AudioStream]


## Get random step audio from list
func random_step() -> AudioStream:
	return step_audios[randi() % step_audios.size()]

extends Node3D

@export_node_path(AudioStreamPlayer3D) var step_audio_path := NodePath("Step")
@onready var step: AudioStreamPlayer3D = get_node(step_audio_path)

@export_node_path(AudioStreamPlayer3D) var land_audio_path := NodePath("Land")
@onready var land: AudioStreamPlayer3D = get_node(land_audio_path)

@export_node_path(AudioStreamPlayer3D) var jump_audio_path := NodePath("Jump")
@onready var jump: AudioStreamPlayer3D = get_node(jump_audio_path)

@export_node_path(AudioStreamPlayer3D) var crouch_audio_path := NodePath("Crouch")
@onready var crouch_audio: AudioStreamPlayer3D = get_node(crouch_audio_path)

@export_node_path(AudioStreamPlayer3D) var uncrouch_audio_path := NodePath("Uncrouch")
@onready var uncrouch_audio: AudioStreamPlayer3D = get_node(uncrouch_audio_path)

@export_node_path(RayCast3D) var raycast_path := NodePath("Detect Ground")
@onready var raycast: RayCast3D = get_node(raycast_path)

@export_node_path(CharacterBody3D) var character_body_path := NodePath("..")
@onready var character_body: CharacterBody3D = get_node(character_body_path)

@export_node_path(CharacterController3D) var character_controller_path := NodePath("..")
@onready var character_controller: CharacterController3D = get_node(character_controller_path)

@export var audio_interact : Resource
@export var physic_materials : Array[PhysicsMaterial]
@export var audio_interacts : Array[Resource]
@export var water_audio_interact : Resource

func _ready():
	pass
	character_controller.stepped.connect(_on_controller_stepped.bind())
	character_controller.crouched.connect(_on_controller_crouched.bind())
	character_controller.jumped.connect(_on_controller_jumped.bind())
	character_controller.landed.connect(_on_controller_landed.bind())
	character_controller.uncrouched.connect(_on_controller_uncrouched.bind())
	character_controller.entered_the_water.connect(_on_controller_entered_the_water.bind())
	character_controller.exit_the_water.connect(_on_controller_exit_the_water.bind())

func _on_controller_jumped():
	jump.stream = audio_interact.jump_audio
	jump.play()
	

func _on_controller_landed():
	_get_audio_interact()
	land.stream = audio_interact.landed_audio
	land.play()
	

func _on_controller_stepped():
	var collision = raycast.get_collider()
	_get_audio_interact_of_object(collision)
	step.stream = audio_interact.random_step()
	step.play()
	
	
func _get_audio_interact():
	var k_col = character_body.get_last_slide_collision()
	var collision = k_col.get_collider(0)
	_get_audio_interact_of_object(collision)
	
	
func _get_audio_interact_of_object(collision):
	if character_controller.is_on_water():
		audio_interact = water_audio_interact
		return
	if !collision:
		return
	if not "physics_material_override" in collision:
		return
	var mat = collision.physics_material_override
	if mat:
		var i = physic_materials.rfind(mat)
		if i != -1:
			audio_interact = audio_interacts[i]
	


func _on_controller_crouched():
	crouch_audio.play()


func _on_controller_uncrouched():
	uncrouch_audio.play()


func _on_controller_entered_the_water():
	audio_interact = water_audio_interact
	land.stream = audio_interact.landed_audio
	land.play()


func _on_controller_exit_the_water():
	jump.stream = audio_interact.jump_audio
	jump.play()

extends Node3D
class_name PlayerAudios3D

## Script that plays sounds based on player actions.
## Using an [AudioInteract] array synchronized with physic_materials array to 
## identify different sound structures for each type of physical material.

@onready var step_stream: AudioStreamPlayer3D = get_node(NodePath("Step"))
@onready var land_stream: AudioStreamPlayer3D = get_node(NodePath("Land"))
@onready var jump_stream: AudioStreamPlayer3D = get_node(NodePath("Jump"))
@onready var crouch_stream: AudioStreamPlayer3D = get_node(NodePath("Crouch"))
@onready var uncrouch_stream: AudioStreamPlayer3D = get_node(NodePath("Uncrouch"))
@onready var raycast: RayCast3D = get_node(NodePath("Detect Ground"))
@onready var character_body: CharacterBody3D = get_node(NodePath(".."))
@onready var character_controller: CharacterController3D = get_node(NodePath(".."))

## Default audio interact used
@export var audio_interact : Resource

## List of [PhysicsMaterial] synchronized with the [AudioInteract] list
@export var physic_materials : Array[PhysicsMaterial]

## List of [AudioInteract] synchronized with the [PhysicsMaterial] list
@export var audio_interacts : Array[Resource]

## Specific case of audio interact that occurs when we are in the water
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
	jump_stream.stream = audio_interact.jump_audio
	jump_stream.play()
	

func _on_controller_landed():
	_get_audio_interact()
	land_stream.stream = audio_interact.landed_audio
	land_stream.play()
	

func _on_controller_stepped():
	var collision = raycast.get_collider()
	_get_audio_interact_of_object(collision)
	step_stream.stream = audio_interact.random_step()
	step_stream.play()
	
	
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
	crouch_stream.play()


func _on_controller_uncrouched():
	uncrouch_stream.play()


func _on_controller_entered_the_water():
	audio_interact = water_audio_interact
	land_stream.stream = audio_interact.landed_audio
	land_stream.play()


func _on_controller_exit_the_water():
	jump_stream.stream = audio_interact.jump_audio
	jump_stream.play()

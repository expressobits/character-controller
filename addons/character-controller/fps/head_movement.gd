extends Marker3D

class_name HeadMovement

@export_node_path("Camera3D") var cam_path := NodePath("Camera")
@onready var cam: Camera3D = get_node(cam_path)

@export var mouse_sensitivity := 0.002
@export var vertical_angle_limit := 90.0
var rot := Vector3()


func set_mouse_sensitivity(sensitivity):
	mouse_sensitivity = sensitivity/1000


func set_vertical_angle_limit(limit : float):
	vertical_angle_limit = deg_to_rad(limit)


func rotate_camera(mouse_axis : Vector2) -> void:
	# Horizontal mouse look.
	rot.y -= mouse_axis.x * mouse_sensitivity
	# Vertical mouse look.
	rot.x = clamp(rot.x - mouse_axis.y * mouse_sensitivity, -vertical_angle_limit, vertical_angle_limit)
	
	get_owner().rotation.y = rot.y
	rotation.x = rot.x

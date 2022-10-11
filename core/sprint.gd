extends Node

class_name Sprint

@export_node_path(Node3D) var head_path := NodePath("../Head")
@onready var cam: Camera3D = get_node(head_path).cam






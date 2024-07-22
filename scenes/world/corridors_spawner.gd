extends Node3D
@export var tunnel_count : int = 10
@export var tunnel_scale : Vector3 = Vector3.ONE
@export var tunnel_scene : PackedScene
@export var tunnel_spacing : float = 10

func _ready() -> void:
	for i in tunnel_count:
		var tunnel = tunnel_scene.instantiate() as Node3D
		add_child(tunnel)
		tunnel.scale = tunnel_scale
		tunnel.position.x = tunnel_spacing * i
		


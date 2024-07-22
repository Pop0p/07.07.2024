extends MeshInstance3D

@export var body : RigidBody3D
@export var amplitude : float = 10.0
@export var speed : float = 5.0
@export var horizontal : bool = true
var time_offset : float = 0
var base_position : float = 0

func _ready() -> void:
	if body == null:
		body = get_node("RigidBody3D")
		if horizontal:
			base_position = position.x
		else:
			base_position = position.y

func _process(delta: float) -> void:
	time_offset += delta * speed
	var new_pos = base_position + amplitude * sin(time_offset)
	if horizontal:
		position.x = new_pos
	else:
		position.y = new_pos
	

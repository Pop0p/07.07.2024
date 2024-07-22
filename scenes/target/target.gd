class_name PracticeTarget extends Node3D

@export var movement_amplitude: float = 10.0
@export var movement_speed: float = 5.0
@export var target_axis: Vector3 = Vector3(0, 0, 0)  # Axe de mouvement par défaut (vertical)

var time_offset: float = 0
var base_position: Vector3 = Vector3.ZERO

func _ready() -> void:
	base_position = position


func _physics_process(delta: float) -> void:
	time_offset += delta * movement_speed
	var movement = movement_amplitude * sin(time_offset)
	var new_pos = base_position + target_axis * movement
	position = new_pos

class_name PlayerInputs extends Node

var is_primary_fire_pressed : bool
var is_primary_fire_just_pressed : bool
var is_secondary_fire_pressed : bool
var is_secondary_fire_just_pressed: bool
var is_reload_pressed : bool
var is_crouch_pressed : bool
var is_jump_pressed : bool
var is_sprint_pressed : bool
var movements : Vector2

var rotation_input : float
var tilt_input : float

func _process(_delta):
	movements = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	is_sprint_pressed = Input.is_action_pressed("move_fast")
	is_primary_fire_pressed = Input.is_action_pressed("primary_fire")
	is_primary_fire_just_pressed = Input.is_action_just_pressed("primary_fire")
	is_secondary_fire_pressed = Input.is_action_pressed("secondary_fire")
	is_secondary_fire_just_pressed = Input.is_action_just_pressed("secondary_fire")
	
	
	#is_reload_pressed = Input.is_action_pressed("reload")
	#is_crouch_pressed = Input.is_action_pressed("crouch")
	#is_jump_pressed = Input.is_action_pressed("jump")

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotation_input += -event.relative.x * 0.001
		tilt_input += -event.relative.y * 0.001

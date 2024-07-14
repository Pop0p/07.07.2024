class_name PlayerController extends CharacterBody3D

@export var camera : Camera3D
@export var inputs : PlayerInputs
@export var animation : AnimationPlayer

@export var stamina : FloatValue

@export var movement_speed : float = 3.5
@export var movement_speed_fast : float = 6.0
@export var movement_acceleration : float = 0.75
@export var movement_deceleration : float = 0.25

@export var mouse_sensitivity : float = .35
var _mouse_rotation : Vector3

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta: float) -> void:
	_update_velocity(delta)
	_update_rotation(delta)
	
func _update_velocity(delta: float) -> void:
	var direction = (transform.basis * Vector3(inputs.movements.x, 0, inputs.movements.y)).normalized()
	if direction:
		velocity.x = lerp(velocity.x, direction.x * (movement_speed_fast if inputs.is_sprint_pressed else movement_speed), movement_acceleration)
		velocity.z = lerp(velocity.z ,direction.z * (movement_speed_fast if inputs.is_sprint_pressed else movement_speed), movement_acceleration)
		if inputs.is_sprint_pressed and animation.current_animation != "Running":
			animation.play("Running", -1, 1.5)
		elif not inputs.is_sprint_pressed and animation.current_animation != "Walking":
			animation.play("Walking", -1, 1.5)
	else:
		velocity.x = move_toward(velocity.x, 0, movement_deceleration)
		velocity.z = move_toward(velocity.z, 0, movement_deceleration)
		if animation.is_playing():
			animation.stop()

func _update_rotation(delta : float) -> void:
	_mouse_rotation.x += inputs.tilt_input * mouse_sensitivity
	_mouse_rotation.x = clamp(_mouse_rotation.x, deg_to_rad(-80), deg_to_rad(80))
	_mouse_rotation.y += inputs.rotation_input * mouse_sensitivity
	
	var _player_rotation = Vector3(0.0, _mouse_rotation.y, 0.0)
	var _camera_rotation = Vector3(_mouse_rotation.x, 0.0, 0.0)
	
	camera.transform.basis = Basis.from_euler(_camera_rotation)
	camera.rotation.z = 0.0
	
	global_transform.basis = Basis.from_euler(_player_rotation)
	
	inputs.rotation_input = 0.0
	inputs.tilt_input = 0.0

func _physics_process(delta: float) -> void:
	move_and_slide()

class_name PlayerController extends CharacterBody3D

@export var camera : Camera3D
@export var inputs : PlayerInputs
@export var animation_player : AnimationPlayer

@export var settings_mouse_sensitivity : float = .35

@export var engine_current_speed : FloatValue

@export var engine_boost_multiplier : float = 2.0
@export var engine_boost_max_movement_speed : float = 65.0
@export var engine_reorientation_rate : float = 1.0
@export var engine_max_movement_speed : float = 45.0
@export var engine_steering_force : float = 14.0
@export var engine_deceleration : float = 15.0
@export var engine_breaking_force : float = 10.0
@export var mass : float = 1.0

@export var movement_speed : float = 5
@export var movement_acceleration : float = 0.75
@export var movement_deceleration : float = 0.25
@export var air_control_speed : float = 2.5
@export var air_control_acceleration : float = 1.0
@export var air_control_deceleration : float = 1.0
@export var gravity : float = -9.8

var _last_input_time : float
var _is_engine_turned_on: bool = false
var _is_flying : bool = false
var _mouse_rotation : Vector3

var _engine_idle_start_y_position : float = 0
var _engine_idle_time : float = 0


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Engine.max_fps = 120
	_is_engine_turned_on = true
	engine_current_speed.set_max_value(engine_boost_max_movement_speed)

func _process(delta: float) -> void:
	_update_rotation(delta)
	if _is_flying:
		_update_engine_velocity(delta)
		if is_on_floor() and (-transform.basis.z).y < 0:
			_is_flying = false
	else:
		_update_human_velocity(delta)
		if is_on_floor() and inputs.is_jump_just_pressed:
			velocity.y += 4
			
	if inputs.is_secondary_fire_just_pressed:
		_is_flying = not _is_flying
		
	

func _update_engine_velocity(delta: float) -> void:
	if _is_engine_turned_on:
		var forward = -camera.global_transform.basis.z.normalized()
		var right = camera.global_transform.basis.x.normalized()
		var orientation = forward + right
		var speed_multiplier : float = engine_boost_multiplier if inputs.is_primary_fire_pressed and velocity.length() < engine_max_movement_speed else 1
		var steering_forward = forward * engine_steering_force * -inputs.movements.y
		var steering_horizontal = right * engine_steering_force * inputs.movements.x
		var steering = (steering_forward + steering_horizontal) * speed_multiplier
		var steering_direction = steering.normalized()
		var steering_force = steering / mass

		if inputs.movements.length() != 0:
			velocity += steering_force * delta
			velocity = velocity.lerp(steering_direction * velocity.length(), engine_reorientation_rate * delta)
			if velocity.length() > engine_max_movement_speed:
				if inputs.is_primary_fire_pressed and velocity.length() > engine_boost_max_movement_speed:
					velocity = velocity.normalized() * engine_boost_max_movement_speed	
				elif not inputs.is_primary_fire_pressed:
					velocity = velocity.normalized() * engine_max_movement_speed
		else:
			velocity = velocity.move_toward(Vector3.ZERO, engine_deceleration * delta)
		
		if velocity.length() <= 0.1:
			if _engine_idle_time == 0:
				_engine_idle_start_y_position = position.y
				_engine_idle_time = 0
			else:
				var target_position_y = _engine_idle_start_y_position + 0.50 * sin(_engine_idle_time)
				position.y = target_position_y
			_engine_idle_time += delta
		else:
			var new_shake : Vector3
			if velocity.length() > (engine_max_movement_speed):
				new_shake = Vector3(randf_range(-0.3, 0.3), randf_range(-0.3, 0.3), 0)
			elif velocity.length() >= (engine_max_movement_speed / 2):
				new_shake = Vector3(randf_range(-0.1, 0.1), randf_range(-0.1, 0.1), 0)
			animation_player.get_animation("engine_moving").track_set_key_value(0, 1, new_shake)
			animation_player.play("engine_moving")
			_engine_idle_time = 0
	else:
		velocity = velocity.move_toward(Vector3.ZERO, engine_breaking_force * delta)

	engine_current_speed.set_value(velocity.length())

func _update_human_velocity(delta: float) -> void:
	var direction = (transform.basis * Vector3(inputs.movements.x, 0, inputs.movements.y)).normalized()
	if is_on_floor():
		if direction != Vector3.ZERO:
			velocity.x = direction.x * movement_speed
			velocity.z = direction.z * movement_speed
		else:
			velocity.x = move_toward(velocity.x, 0, movement_deceleration)
			velocity.z = move_toward(velocity.z, 0, movement_deceleration)
	else:
		velocity.y += gravity * delta
		if direction != Vector3.ZERO:
			velocity.x = move_toward(velocity.x, direction.x * air_control_speed, air_control_acceleration * delta)
			velocity.z = move_toward(velocity.z, direction.z * air_control_speed, air_control_acceleration * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, air_control_deceleration * delta)
			velocity.z = move_toward(velocity.z, 0, air_control_deceleration * delta)

func _update_rotation(delta: float) -> void:
	_mouse_rotation.y += inputs.tilt_input * settings_mouse_sensitivity
	_mouse_rotation.y = clamp(_mouse_rotation.y, deg_to_rad(-85), deg_to_rad(85))
	_mouse_rotation.x += inputs.rotation_input * settings_mouse_sensitivity
	
	var _player_rotation = Vector3(0.0, _mouse_rotation.x, 0.0)
	var _camera_rotation = Vector3(_mouse_rotation.y, 0.0, 0.0)
	
	camera.transform.basis = Basis.from_euler(_camera_rotation)
	camera.rotation.z = 0.0
	global_transform.basis = Basis.from_euler(_player_rotation)
	inputs.rotation_input = 0.0
	inputs.tilt_input = 0.0

func _physics_process(delta: float) -> void:
	move_and_slide()

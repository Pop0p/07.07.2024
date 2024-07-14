class_name PlayerController extends CharacterBody3D

@export var camera : Camera3D
@export var inputs : PlayerInputs
@export var animation_player : AnimationPlayer

@export var settings_mouse_sensitivity : float = .35

@export var engine_current_speed : FloatValue

@export var engine_boost_multiplier : float = 3.5
@export var engine_boost_max_movement_speed : float = 75.0
@export var engine_reorientation_rate : float = 1.0
@export var engine_max_movement_speed : float = 55.0
@export var engine_steering_force : float = 10.0
@export var engine_deceleration : float = 5.0
@export var engine_breaking_force : float = 10.0
@export var mass : float = 1.0

var _last_input_time : float
var _is_engine_turned_on: bool = false
var _mouse_rotation : Vector3

var _engine_idle_start_y_position : float = 0
var _engine_idle_time : float = 0


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	engine_current_speed.set_max_value(engine_boost_max_movement_speed)
	_is_engine_turned_on = true

func _process(delta: float) -> void:
	_update_velocity(delta)
	_update_rotation(delta)

func _update_velocity(delta: float) -> void:
	if _is_engine_turned_on:
		var forward = -global_basis.z.normalized()
		var right = global_basis.x.normalized()
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
			velocity = velocity.move_toward(Vector3.ZERO, engine_deceleration  * delta)
		
		if velocity.length() <= 0.1:
			if _engine_idle_time == 0:
				_engine_idle_start_y_position = position.y
				_engine_idle_time = 0
			else:
				var target_position_y = _engine_idle_start_y_position + 0.25 * sin(_engine_idle_time)
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

func _update_rotation(delta: float) -> void:
	_mouse_rotation.y += inputs.tilt_input * settings_mouse_sensitivity
	_mouse_rotation.y = clamp(_mouse_rotation.y, deg_to_rad(-60), deg_to_rad(60))
	_mouse_rotation.x += inputs.rotation_input * settings_mouse_sensitivity
	
	var _rotation = Vector3(_mouse_rotation.y, _mouse_rotation.x, 0.0)
	global_transform.basis = Basis.from_euler(_rotation)
	
	

	inputs.rotation_input = 0.0
	inputs.tilt_input = 0.0

func _physics_process(delta: float) -> void:
	move_and_slide()

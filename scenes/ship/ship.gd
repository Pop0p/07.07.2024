extends RigidBody3D

@export var engine_steer_force : float = 0.75
@export var engine_max_movement_speed : float = 55.0
@export var engine_slowing_radius : float = 10
@export var engine_stopping_distance : float = 10
@export var flee: bool = false
@export var engine_dodging_distance : float = 10
var _engine_idle_start_y_position : float = 0
var _engine_idle_time : float = 0
var _engine_velocity : Vector3 = Vector3.ZERO
var current_target : int = 0
var _sensor_init_position : Vector3 = Vector3.ZERO
@export var targets : Array[Node3D] = []
@export var seek_force : float = 1
@export var avoid_force : float = 3.0
@export var pursuit_force : float = 1
@export var escape_force : float = 0.5
@export var debug : bool = false

@onready var shapecast_sensor : ShapeCast3D = $"ShapeCast3D"
@onready var raycast_sensor : RayCast3D = $"RayCast3D"

func _ready():
	_sensor_init_position = shapecast_sensor.target_position

func _physics_process(delta: float) -> void:
	var steering = Vector3.ZERO
	var primary_target = targets[current_target]
	#steering += _pursuit(primary_target.global_position, (primary_target as CharacterBody3D).velocity, engine_max_movement_speed)  * seek_force
	#steering += _avoid(primary_target.global_position) * avoid_force
	
	_engine_velocity += steering
	
	if _engine_velocity.length() > engine_max_movement_speed:
		_engine_velocity = _engine_velocity.normalized() * engine_max_movement_speed


	if (primary_target.global_position - global_position).length() < 45:
		current_target = randi() % targets.size()
	
	if _engine_velocity.length() <= 1:
		if _engine_idle_time == 0:
			_engine_idle_start_y_position = position.y
			_engine_idle_time = 0
		else:
			var target_position_y = _engine_idle_start_y_position + 0.25 * sin(_engine_idle_time)
			position.y = target_position_y
		_engine_idle_time += delta
		look_at(primary_target.position, Vector3.UP)
	else:
		_engine_idle_time = 0
		move_and_collide(_engine_velocity * delta)
		look_at(_engine_velocity + position, Vector3.UP)
	if debug:
		DebugDraw3D.draw_line(position, position + _engine_velocity, Color.GRAY)
	
func _seek(target: Vector3) -> Vector3:
	var direction = (target - global_position).normalized()
	var new_target = target - direction * engine_stopping_distance
	var distance = (new_target - global_position).length()
	var desired_velocity = (new_target - global_position).normalized() * engine_max_movement_speed

	if distance < engine_slowing_radius and engine_slowing_radius > 0:
		desired_velocity *= (distance / (engine_slowing_radius))
		
	return _steer(desired_velocity)
	
func _pursuit(target: Vector3, target_velocity: Vector3, target_max_speed: float) -> Vector3:
	var distance = (target - global_position).length()
	var ahead_of_time = distance / target_max_speed
	var futur_position = target + target_velocity * ahead_of_time
	if flee:
		return _flee(futur_position)
	else:
		return _seek(futur_position)

func _avoid(target: Vector3) -> Vector3:
	var desired_velocity : Vector3 = Vector3.ZERO
	var target_distance = (target - position).length()
	
	if shapecast_sensor.target_position.length() > target_distance and not flee:
		shapecast_sensor.target_position = shapecast_sensor.target_position.normalized() * target_distance
		shapecast_sensor.force_shapecast_update()

	if not shapecast_sensor.is_colliding():
		shapecast_sensor.target_position = _sensor_init_position
		if debug:
			DebugDraw3D.draw_line(position, shapecast_sensor.to_global(shapecast_sensor.target_position), Color.GREEN)
			DebugDraw3D.draw_sphere(shapecast_sensor.to_global(shapecast_sensor.target_position), 1.25, Color.GREEN)
		return desired_velocity
	if debug:
		print("collide")
		DebugDraw3D.draw_line(position, shapecast_sensor.to_global(shapecast_sensor.target_position), Color.RED)
		DebugDraw3D.draw_sphere(shapecast_sensor.to_global(shapecast_sensor.target_position), 1.25, Color.RED)
	var radius_increment = [5, 20, 80, 0]
	radius_increment.shuffle()
	var angle_increment = 360 / 40
	for n in range(4):
		var should_break = false
		for i in range(40):
			var angle = deg_to_rad(i * angle_increment)
			var forward = -global_transform.basis.z.normalized()
			var direction = Vector3.ZERO
			if radius_increment[n] == 0:
				var goldenRatio = (1 + sqrt(5)) / 2;
				var angleIncrement = PI * 2 * goldenRatio;
				var t : float = i / 40.0
				var inclination = acos(1 - 2 * t)
				var azimuth = angleIncrement * i
				direction.x = sin(inclination) * cos(azimuth)
				direction.y = sin(inclination) * sin(azimuth)
				direction.z = cos(inclination)
				direction *= _sensor_init_position.length()
			else:
				direction = Vector3(cos(angle) * radius_increment[n], sin(angle) * radius_increment[n], -1 * _sensor_init_position.length())
				
			raycast_sensor.target_position = direction
			raycast_sensor.force_raycast_update()
			if not raycast_sensor.is_colliding():
				shapecast_sensor.target_position = direction
				shapecast_sensor.force_shapecast_update()
				if not shapecast_sensor.is_colliding():
					if debug:
						DebugDraw3D.draw_line(position,raycast_sensor.to_global(raycast_sensor.target_position), Color.LIGHT_GREEN)
					should_break = true
					break
			if debug:
				DebugDraw3D.draw_line(position,raycast_sensor.to_global(raycast_sensor.target_position), Color.RED, 0.25)
		if should_break:
			desired_velocity = _steer(raycast_sensor.to_global(raycast_sensor.target_position) - position)
			break
	
	shapecast_sensor.target_position = _sensor_init_position
	shapecast_sensor.force_shapecast_update()
	if debug:
		DebugDraw3D.draw_line(position, position + desired_velocity, Color.BLUE)
	return desired_velocity



func _flee(target: Vector3) -> Vector3:
	var distance = (target - global_position).length()
	var desired_velocity = (global_position - target).normalized() * engine_max_movement_speed
	
	# Arrival
	if distance > engine_slowing_radius and engine_slowing_radius > 0:
		desired_velocity *= (engine_slowing_radius / distance)

	return _steer(desired_velocity)

func _steer(target: Vector3) -> Vector3:
	var steering = target - _engine_velocity
	if steering.length() > engine_steer_force:
		steering = steering.normalized() * engine_steer_force
	return steering / mass

extends RigidBody3D

@export var target : Node3D
@export var speed : float = 15
@export var max_steering_force : float = 10
@export var max_speed : float = 25
@export var logs : bool = false
@export var escape_range : float = 100

@export var chaser : bool = true

@export var CIRCLE_DISTANCE: float = 5.0
@export var CIRCLE_RADIUS: float = 2.5
@export var CIRCLE_JITTER: float = 1.0
var _wander_angle : float = 5

func _process(delta: float) -> void:
	if target == null:
		return
		
	var target_position = _pursuit(target.position, (target as PhysicsBody3D).linear_velocity)
	var desired_velocity : Vector3
	if chaser:
		desired_velocity = _seek(target_position, position)
	else:
		desired_velocity = _wander()

	desired_velocity = _steer(desired_velocity)
	move_and_collide(desired_velocity * delta)
	
func _seek(a_position : Vector3, b_position : Vector3) -> Vector3:
	return (a_position - b_position).normalized() * speed
func _pursuit(target_position : Vector3, target_velocity: Vector3) -> Vector3:
	var distance = (target.position - position).length()
	var T : float = distance / max_speed
	var futur_position : Vector3 = target_position + target_velocity.normalized() * T
	return futur_position
func _steer(desired_velocity : Vector3) -> Vector3: 
	var steering = desired_velocity - linear_velocity
	if steering.length() > max_steering_force:
		steering = steering.normalized() * max_steering_force
	steering = steering / mass
	var applied_velocity = linear_velocity + steering
	if applied_velocity.length() > max_speed:
		applied_velocity = applied_velocity.normalized() * max_speed
	return desired_velocity
func _wander() -> Vector3:
	# Calculer le centre du cercle devant le personnage
	var circle_center: Vector3 = linear_velocity.normalized() * CIRCLE_DISTANCE
	# Calculer un déplacement aléatoire sur le cercle
	var displacement: Vector3 = Vector3(randf() - 0.5, randf() - 0.5, randf() - 0.5).normalized() * CIRCLE_RADIUS
	# Appliquer du jitter (bruit) pour rendre le déplacement plus erratique
	displacement += Vector3(cos(_wander_angle) * displacement.length(), sin(_wander_angle) * displacement.length(), sin(_wander_angle) * displacement.length())
	
	# La position finale de l'errance est le centre du cercle plus le déplacement
	var wander_force: Vector3 = circle_center + displacement
	return wander_force.normalized() * speed

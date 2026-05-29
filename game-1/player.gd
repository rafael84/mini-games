extends CharacterBody3D


const SPEED = 16.0
const ACCELERATION = 12.0
const DECELERATION = 6.0
const TURN_ACCELERATION = 48.0
const PUSH_FORCE = 0.04
const JUMP_VELOCITY = 5

const BALL_RADIUS = 0.5

@onready var ball_mesh: CSGMesh3D = %CSGMesh3D
	

func _physics_process(delta: float) -> void:
	
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
		return
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	var horizontal_velocity: Vector3 = Vector3(velocity.x, 0.0, velocity.z)
	
	if direction:
		var target_velocity: Vector3 = direction * SPEED
		var acceleration_to_use: float = ACCELERATION
		
		if horizontal_velocity.length() > 0.01:
			var current_direction: Vector3 = horizontal_velocity.normalized()
			var direction_dot: float = current_direction.dot(direction)
			if direction_dot < 0.3:
				acceleration_to_use = TURN_ACCELERATION
		
		velocity.x = move_toward(velocity.x, target_velocity.x, acceleration_to_use * delta)
		velocity.z = move_toward(velocity.z, target_velocity.z, acceleration_to_use * delta)
		
	else:
		velocity.x = move_toward(velocity.x, 0.0, DECELERATION * delta)
		velocity.z = move_toward(velocity.z, 0.0, DECELERATION * delta)

	var velocity_before_slide: Vector3 = velocity
	move_and_slide()
	
	_rotate_ball_visual(delta)
	_push_rigid_bodies(velocity_before_slide)

func _rotate_ball_visual(delta: float) -> void:
	var horizontal_velocity: Vector3 = Vector3(velocity.x, 0.0, velocity.z)

	if horizontal_velocity.length() < 0.01:
		return

	var move_distance: float = horizontal_velocity.length() * delta
	var rotation_amount: float = move_distance / BALL_RADIUS
	var move_direction: Vector3 = horizontal_velocity.normalized()

	var rotation_axis: Vector3 = Vector3.UP.cross(move_direction).normalized()

	ball_mesh.global_rotate(rotation_axis, rotation_amount)

func _push_rigid_bodies(push_velocity: Vector3) -> void:
	var horizontal_velocity: Vector3 = Vector3(push_velocity.x, 0.0, push_velocity.z)
	var ball_speed: float = horizontal_velocity.length()

	if ball_speed < 0.01:
		return

	for i: int in get_slide_collision_count():
		var collision: KinematicCollision3D = get_slide_collision(i)
		var collider: Object = collision.get_collider()

		if collider is RigidBody3D:
			var body: RigidBody3D = collider as RigidBody3D

			# Direção do empurrão: direção real da bola antes da colisão
			var push_direction: Vector3 = horizontal_velocity.normalized()

			var impulse_strength: float = ball_speed * PUSH_FORCE
			impulse_strength = clampf(impulse_strength, 0.02, 2.0)

			var impulse: Vector3 = push_direction * impulse_strength

			# Aplica acima do centro para derrubar, não só deslizar
			var hit_offset: Vector3 = collision.get_position() - body.global_position
			hit_offset.y = max(hit_offset.y, 0.6)

			print("ball_speed: ", ball_speed, " impulse: ", impulse_strength)
			body.apply_impulse(impulse, hit_offset)

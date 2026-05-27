extends CharacterBody3D

enum State { PATROL, CHASE, ATTACK }

const MOVE_SPEED := 1.6
const DETECT_RANGE := 8.0
const ATTACK_RANGE := 1.0
const PATROL_RADIUS := 1.7

@export var player_path: NodePath = ^"../Player"

var _player: CharacterBody3D
var _spawn_position: Vector3
var _patrol_phase: float = 0.0
var state: State = State.PATROL

var player_in_attack_range: bool = false


func _ready() -> void:
	_player = get_node(player_path) as CharacterBody3D


func set_spawn(pos: Vector3) -> void:
	global_position = pos
	_spawn_position = pos


func _physics_process(delta: float) -> void:
	if _player == null:
		return

	player_in_attack_range = false
	var player_pos := _player.global_position
	var to_player := player_pos - global_position
	var dist := to_player.length()

	var in_range := dist <= DETECT_RANGE
	var has_los := false
	if in_range:
		has_los = _has_line_of_sight(global_position + Vector3(0, 1.0, 0), player_pos)

	if has_los and dist <= ATTACK_RANGE:
		state = State.ATTACK
		player_in_attack_range = true
		velocity = Vector3.ZERO
		GameManager.on_player_caught()
		move_and_slide()
		return

	state = State.CHASE if has_los else State.PATROL

	var target := global_position
	match state:
		State.PATROL:
			_patrol_phase += delta
			target = _spawn_position + Vector3(
				sin(_patrol_phase) * PATROL_RADIUS,
				0.0,
				cos(_patrol_phase) * PATROL_RADIUS
			)
		State.CHASE:
			target = Vector3(player_pos.x, global_position.y, player_pos.z)

	var to_target := target - global_position
	to_target.y = 0.0
	if to_target.length_squared() > 0.0001:
		var dir := to_target.normalized()
		velocity.x = dir.x * MOVE_SPEED
		velocity.z = dir.z * MOVE_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, MOVE_SPEED)
		velocity.z = move_toward(velocity.z, 0.0, MOVE_SPEED)

	move_and_slide()


func _has_line_of_sight(from: Vector3, to: Vector3) -> bool:
	var space := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = false
	query.collide_with_bodies = true
	query.collision_mask = 1
	query.exclude = [get_rid(), _player.get_rid()]

	var result := space.intersect_ray(query)
	if result.is_empty():
		return true
	# Hit something — blocked unless it's very close to the target (player).
	var hit_dist := from.distance_to(result.position)
	return hit_dist >= from.distance_to(to) - 0.5

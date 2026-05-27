extends CharacterBody3D

const MOVE_SPEED := 3.0
const MOUSE_SENSITIVITY := 0.0022
const MAX_PITCH := 1.5

@onready var camera: Camera3D = $Camera3D
@onready var flashlight: SpotLight3D = $Camera3D/Flashlight
@onready var enemy: Node3D = get_node_or_null("../Enemy")

var _pitch: float = 0.0
var _base_flashlight_energy: float = 2.0


func _ready() -> void:
	_base_flashlight_energy = flashlight.light_energy
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event: InputEvent) -> void:
	# Web: first click captures pointer for mouse-look.
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if not GameManager.can_control:
			return
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		_pitch = clampf(_pitch - event.relative.y * MOUSE_SENSITIVITY, -MAX_PITCH, MAX_PITCH)
		camera.rotation.x = _pitch


func _physics_process(_delta: float) -> void:
	if not GameManager.can_control:
		velocity = Vector3.ZERO
		return

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	if direction.length_squared() > 0.0001:
		velocity.x = direction.x * MOVE_SPEED
		velocity.z = direction.z * MOVE_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, MOVE_SPEED)
		velocity.z = move_toward(velocity.z, 0.0, MOVE_SPEED)

	move_and_slide()
	_update_atmosphere()


func _update_atmosphere() -> void:
	if enemy == null:
		return

	var to_enemy := enemy.global_position - global_position
	to_enemy.y = 0.0
	var dist := to_enemy.length()
	var prox := clampf(1.0 - dist / 12.0, 0.0, 1.0)
	GameManager.proximity_to_enemy = prox

	var flicker := 1.0 + prox * 0.25 * (sin(Time.get_ticks_msec() * 0.038) * 0.7 + sin(Time.get_ticks_msec() * 0.009) * 0.3)
	flashlight.light_energy = _base_flashlight_energy * clampf(flicker, 0.5, 1.4)

	if prox > 0.001:
		var shake := 0.04 * prox
		var t := Time.get_ticks_msec() * 0.001
		camera.position = Vector3(
			sin(t * 60.0) * shake + sin(t * 35.0) * shake,
			sin(t * 50.0) * shake * 0.35,
			0.0
		)
	else:
		camera.position = Vector3.ZERO

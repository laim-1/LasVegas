extends Node3D

@onready var _hud: Label = $UI/HUD/StatusLabel
@onready var _level: HorrorLevel = $Level
@onready var _player: CharacterBody3D = $Player
@onready var _enemy: CharacterBody3D = $Enemy


func _ready() -> void:
	_player.global_position = _level.get_player_spawn()
	var enemy_spawn: Vector3 = _level.get_enemy_spawn()
	if _enemy.has_method(&"set_spawn"):
		_enemy.set_spawn(enemy_spawn)
	else:
		_enemy.global_position = enemy_spawn


func _process(_delta: float) -> void:
	_hud.text = GameManager.get_status_text()

	# Full proximity when enemy is attacking
	if _enemy.player_in_attack_range:
		GameManager.proximity_to_enemy = 1.0

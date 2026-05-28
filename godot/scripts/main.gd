extends Node3D

@onready var _hud: Label = $UI/HUD/StatusLabel
@onready var _reload_btn: Button = $UI/HUD/ReloadButton
@onready var _level: HorrorLevel = $Level
@onready var _player: CharacterBody3D = $Player


func _ready() -> void:
	_player.global_position = _level.get_player_spawn()
	_reload_btn.pressed.connect(_on_reload_pressed)


func _process(_delta: float) -> void:
	_hud.text = GameManager.get_status_text()


func _on_reload_pressed() -> void:
	GameManager.reload_from_ui()

extends Node
## Global game state. Explore mode: walk the map with no monster or timer pressure.

enum Mode { PLAYING, DEAD, WON }

const EXPLORE_MODE := true

var mode: Mode = Mode.PLAYING
var elapsed_seconds: float = 0.0
var proximity_to_enemy: float = 0.0

var can_control: bool:
	get:
		return mode == Mode.PLAYING


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("reload_page"):
		_reload_web_page()

	if Input.is_action_just_pressed("restart"):
		restart()

	if EXPLORE_MODE:
		return

	if mode != Mode.PLAYING:
		return

	elapsed_seconds += delta
	if elapsed_seconds >= 30.0:
		mode = Mode.WON


func on_player_caught() -> void:
	if EXPLORE_MODE:
		return
	if mode == Mode.PLAYING:
		mode = Mode.DEAD


func _reload_web_page() -> void:
	if OS.has_feature("web"):
		if JavaScriptBridge.eval("typeof window.reloadLasVegasGame === 'function'", true):
			JavaScriptBridge.eval("window.reloadLasVegasGame();", true)
		else:
			JavaScriptBridge.eval(
				"location.replace(location.pathname + '?t=' + Date.now());", true
			)
	else:
		restart()


func restart() -> void:
	mode = Mode.PLAYING
	elapsed_seconds = 0.0
	proximity_to_enemy = 0.0
	get_tree().reload_current_scene()


func get_status_text() -> String:
	if EXPLORE_MODE:
		return "Explore — WASD move, mouse look | Q restart | F5 reload page"
	match mode:
		Mode.PLAYING:
			var remaining := maxf(0.0, 30.0 - elapsed_seconds)
			return "Survive: %.1fs  (WASD move, mouse look, Q restart)" % remaining
		Mode.DEAD:
			return "You were caught. Press Q to restart."
		Mode.WON:
			return "You survived! Press Q to play again."
	return ""

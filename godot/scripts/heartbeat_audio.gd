extends AudioStreamPlayer
## Procedural ambient + heartbeat; volume follows GameManager.proximity_to_enemy.

const MIX_RATE := 44100.0
const BUFFER_SEC := 0.08

var _playback: AudioStreamGeneratorPlayback
var _time: float = 0.0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _ambient_lp: float = 0.0


func _ready() -> void:
	# Audio disabled (removes clicking/artefacts in web builds).
	stream = null
	stop()
	set_process(false)
	return


func _process(_delta: float) -> void:
	return
	if _playback == null:
		return

	var frames_available := _playback.get_frames_available()
	if frames_available < 64:
		return

	var proximity := GameManager.proximity_to_enemy
	if GameManager.mode != GameManager.Mode.PLAYING:
		proximity *= 0.2

	var to_fill := mini(frames_available, int(MIX_RATE * BUFFER_SEC))
	for i in to_fill:
		_time += 1.0 / MIX_RATE

		_rng.randf()
		var noise := _rng.randf_range(-1.0, 1.0)
		var amb_target := 0.015 * (0.3 + proximity) * noise
		_ambient_lp = _ambient_lp * 0.98 + amb_target * 0.02

		var min_interval := lerpf(1.2, 0.35, proximity)
		var phase := fmod(_time, min_interval)
		var beat_len := min_interval * 0.18
		var env := exp(-(phase / beat_len) * 10.0) if phase < beat_len else 0.0
		var tone_hz := 45.0 + 30.0 * proximity
		var thump := sin(TAU * tone_hz * _time) * env
		var heartbeat := thump * (0.25 + 0.85 * proximity)

		var sample := _ambient_lp * 0.35 + heartbeat
		sample = clampf(sample, -1.0, 1.0)
		_playback.push_frame(Vector2(sample, sample * 0.95))

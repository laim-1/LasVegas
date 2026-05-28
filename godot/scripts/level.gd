extends Node3D
class_name HorrorLevel
## Procedural cul-de-sac neighborhood: street, houses, park.

const GROUP_LEVEL := &"level_geometry"

# --- Palette ---
const COL_ASPHALT := Color(0.22, 0.24, 0.26)
const COL_SIDEWALK := Color(0.55, 0.56, 0.58)
const COL_GRASS := Color(0.28, 0.45, 0.25)
const COL_WALL_FAKE := Color(0.58, 0.54, 0.5)
const COL_WALL_REAL := Color(0.72, 0.62, 0.52)
const COL_ROOF := Color(0.32, 0.22, 0.2)
const COL_ROOF_TRIM := Color(0.45, 0.3, 0.25)
const COL_WINDOW := Color(0.55, 0.7, 0.82)
const COL_YELLOW_LINE := Color(0.85, 0.75, 0.2)
const COL_TREE_TRUNK := Color(0.35, 0.22, 0.12)
const COL_TREE_CANOPY := Color(0.2, 0.42, 0.22)
const COL_BENCH := Color(0.45, 0.3, 0.2)
const COL_INTERIOR_FLOOR := Color(0.4, 0.38, 0.35)
const COL_INTERIOR_WALL := Color(0.5, 0.48, 0.44)
const COL_CURB := Color(0.48, 0.49, 0.52)
const COL_FOUNDATION := Color(0.42, 0.4, 0.38)
const COL_TRIM := Color(0.88, 0.86, 0.82)
const COL_DOOR := Color(0.32, 0.2, 0.12)
const COL_HEDGE := Color(0.18, 0.38, 0.2)

# Grass sits lower; pavement sits on top so they never z-fight.
const GRASS_Y := -0.14
const GRASS_THICK := 0.1
const PAVE_Y := 0.02
const PAVE_THICK := 0.12
const GROUND_TOP := PAVE_Y + PAVE_THICK

const WALL_Y0 := GROUND_TOP
const WALL_H := 5.2
const WALL_T := 0.28

enum HouseFacing { PLUS_Z, MINUS_Z, PLUS_X, MINUS_X }

var _real_house_center := Vector3.ZERO


func _ready() -> void:
	_build_neighborhood()


func _add_box(box_min: Vector3, box_max: Vector3, color: Color) -> void:
	var size := box_max - box_min
	var center := (box_min + box_max) * 0.5

	var body := StaticBody3D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	body.add_to_group(GROUP_LEVEL)

	var mesh_inst := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = size
	mesh_inst.mesh = box_mesh
	mesh_inst.position = center

	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mesh_inst.material_override = mat

	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	col.shape = shape
	col.position = center

	body.add_child(mesh_inst)
	body.add_child(col)
	add_child(body)


func _add_grass(x0: float, z0: float, x1: float, z1: float) -> void:
	var y1 := GRASS_Y + GRASS_THICK
	_add_box(Vector3(x0, GRASS_Y, z0), Vector3(x1, y1, z1), COL_GRASS)


func _add_pavement(x0: float, z0: float, x1: float, z1: float, color: Color) -> void:
	var y1 := PAVE_Y + PAVE_THICK
	_add_box(Vector3(x0, PAVE_Y, z0), Vector3(x1, y1, z1), color)


func _add_wall_segment(
		axis: String,
		fixed: float,
		span_a0: float,
		span_a1: float,
		span_b: float,
		color: Color,
		door_center: float = INF,
		door_half_width: float = 0.0
) -> void:
	var y1 := WALL_Y0 + WALL_H
	if door_half_width > 0.0 and door_center < INF:
		var d0 := door_center - door_half_width
		var d1 := door_center + door_half_width
		if span_a0 < d0:
			_add_wall_segment(axis, fixed, span_a0, d0, span_b, color)
		if d1 < span_a1:
			_add_wall_segment(axis, fixed, d1, span_a1, span_b, color)
		return

	if axis == "x":
		var x0 := fixed - span_b * 0.5
		var x1 := fixed + span_b * 0.5
		_add_box(Vector3(x0, WALL_Y0, span_a0), Vector3(x1, y1, span_a1), color)
	else:
		var z0 := fixed - span_b * 0.5
		var z1 := fixed + span_b * 0.5
		_add_box(Vector3(span_a0, WALL_Y0, z0), Vector3(span_a1, y1, z1), color)


func _add_trim_band(axis: String, fixed: float, span_a0: float, span_a1: float, depth: float) -> void:
	var trim_h := 0.22
	var y0 := WALL_Y0 + WALL_H - trim_h
	var y1 := WALL_Y0 + WALL_H
	if axis == "z":
		_add_box(
			Vector3(span_a0, y0, fixed - depth * 0.5),
			Vector3(span_a1, y1, fixed + depth * 0.5),
			COL_TRIM
		)
	else:
		_add_box(
			Vector3(fixed - depth * 0.5, y0, span_a0),
			Vector3(fixed + depth * 0.5, y1, span_a1),
			COL_TRIM
		)


func _add_roof(cx: float, cz: float, half_w: float, half_d: float, facing: HouseFacing) -> void:
	var y0 := WALL_Y0 + WALL_H
	var y_main := y0 + 0.42
	_add_box(
		Vector3(cx - half_w - 0.2, y0, cz - half_d - 0.2),
		Vector3(cx + half_w + 0.2, y_main, cz + half_d + 0.2),
		COL_ROOF
	)
	# Front gable peak.
	var gable_h := 1.1
	var gable_d := 0.55
	match facing:
		HouseFacing.PLUS_Z:
			_add_box(
				Vector3(cx - half_w * 0.55, y_main, cz + half_d - 0.1),
				Vector3(cx + half_w * 0.55, y_main + gable_h, cz + half_d + gable_d),
				COL_ROOF_TRIM
			)
		HouseFacing.MINUS_Z:
			_add_box(
				Vector3(cx - half_w * 0.55, y_main, cz - half_d - gable_d),
				Vector3(cx + half_w * 0.55, y_main + gable_h, cz - half_d + 0.1),
				COL_ROOF_TRIM
			)
		HouseFacing.PLUS_X:
			_add_box(
				Vector3(cx + half_w - 0.1, y_main, cz - half_d * 0.55),
				Vector3(cx + half_w + gable_d, y_main + gable_h, cz + half_d * 0.55),
				COL_ROOF_TRIM
			)
		HouseFacing.MINUS_X:
			_add_box(
				Vector3(cx - half_w - gable_d, y_main, cz - half_d * 0.55),
				Vector3(cx - half_w + 0.1, y_main + gable_h, cz + half_d * 0.55),
				COL_ROOF_TRIM
			)
	# Chimney.
	_add_box(
		Vector3(cx + half_w * 0.35, y_main, cz - half_d * 0.5),
		Vector3(cx + half_w * 0.35 + 0.55, y_main + 1.35, cz - half_d * 0.5 + 0.55),
		COL_FOUNDATION
	)


func _add_windows_on_wall(
		axis: String,
		fixed: float,
		span_a0: float,
		span_a1: float,
		depth: float,
		count: int
) -> void:
	var win_h := 1.35
	var win_w := 1.1
	var y0 := WALL_Y0 + 1.65
	var y1 := y0 + win_h
	var margin := 1.4
	var usable := span_a1 - span_a0 - margin * 2.0
	if count < 1 or usable <= win_w:
		return
	var step := usable / float(count)
	for i in count:
		var center_a := span_a0 + margin + step * (float(i) + 0.5)
		if axis == "z":
			_add_box(
				Vector3(center_a - win_w * 0.5, y0, fixed - depth * 0.55),
				Vector3(center_a + win_w * 0.5, y1, fixed + depth * 0.55),
				COL_WINDOW
			)
			# Window sill.
			_add_box(
				Vector3(center_a - win_w * 0.55, y0 - 0.08, fixed - depth * 0.6),
				Vector3(center_a + win_w * 0.55, y0, fixed + depth * 0.6),
				COL_TRIM
			)
		else:
			_add_box(
				Vector3(fixed - depth * 0.55, y0, center_a - win_w * 0.5),
				Vector3(fixed + depth * 0.55, y1, center_a + win_w * 0.5),
				COL_WINDOW
			)
			_add_box(
				Vector3(fixed - depth * 0.6, y0 - 0.08, center_a - win_w * 0.55),
				Vector3(fixed + depth * 0.6, y0, center_a + win_w * 0.55),
				COL_TRIM
			)


func _add_house_lawn(cx: float, cz: float, half_w: float, half_d: float, facing: HouseFacing) -> void:
	var pad := 2.2
	var lx0 := cx - half_w - pad
	var lx1 := cx + half_w + pad
	var lz0 := cz - half_d - pad
	var lz1 := cz + half_d + pad
	# Keep lawn off the asphalt — shrink toward house on street side.
	match facing:
		HouseFacing.PLUS_Z:
			lz1 = cz + half_d + pad * 0.6
		HouseFacing.MINUS_Z:
			lz0 = cz - half_d - pad * 0.6
		HouseFacing.PLUS_X:
			lx1 = cx + half_w + pad * 0.6
		HouseFacing.MINUS_X:
			lx0 = cx - half_w - pad * 0.6
	_add_grass(lx0, lz0, lx1, lz1)


func _add_house_foundation(cx: float, cz: float, half_w: float, half_d: float) -> void:
	var fh := 0.35
	_add_box(
		Vector3(cx - half_w - 0.15, WALL_Y0 - fh, cz - half_d - 0.15),
		Vector3(cx + half_w + 0.15, WALL_Y0, cz + half_d + 0.15),
		COL_FOUNDATION
	)


func _add_porch_at_front(cx: float, cz: float, facing: HouseFacing, half_d: float, enterable: bool) -> void:
	if not enterable:
		return
	var step_h := 0.16
	var plat_d := 1.2
	var plat_w := 2.6
	match facing:
		HouseFacing.PLUS_Z:
			var fz := cz + half_d
			_add_box(Vector3(cx - plat_w * 0.5, WALL_Y0 - step_h, fz), Vector3(cx + plat_w * 0.5, WALL_Y0, fz + step_h), COL_FOUNDATION)
			_add_box(Vector3(cx - plat_w * 0.5, WALL_Y0, fz + step_h), Vector3(cx + plat_w * 0.5, WALL_Y0 + 0.1, fz + step_h + plat_d), COL_SIDEWALK)
			# Door.
			_add_box(Vector3(cx - 0.45, WALL_Y0 + 0.1, fz - 0.08), Vector3(cx + 0.45, WALL_Y0 + 2.15, fz + 0.12), COL_DOOR)
		HouseFacing.MINUS_Z:
			var fz2 := cz - half_d - plat_d
			_add_box(Vector3(cx - plat_w * 0.5, WALL_Y0 - step_h, fz2), Vector3(cx + plat_w * 0.5, WALL_Y0, fz2 + step_h), COL_FOUNDATION)
			_add_box(Vector3(cx - plat_w * 0.5, WALL_Y0, fz2 + step_h), Vector3(cx + plat_w * 0.5, WALL_Y0 + 0.1, cz - half_d), COL_SIDEWALK)
		_:
			pass


func _add_house(cx: float, cz: float, facing: HouseFacing, enterable: bool) -> void:
	var half_w := 4.6
	var half_d := 3.6
	var wall_col := COL_WALL_REAL if enterable else COL_WALL_FAKE
	var door_half := 0.72 if enterable else 0.0

	if enterable:
		_real_house_center = Vector3(cx, 0.0, cz)

	_add_house_lawn(cx, cz, half_w, half_d, facing)
	_add_house_foundation(cx, cz, half_w, half_d)

	match facing:
		HouseFacing.PLUS_Z:
			var fz := cz + half_d
			_add_wall_segment("z", fz, cx - half_w, cx + half_w, WALL_T, wall_col, cx, door_half)
			_add_trim_band("z", fz, cx - half_w, cx + half_w, WALL_T)
			_add_wall_segment("z", cz - half_d, cx - half_w, cx + half_w, WALL_T, wall_col)
			_add_wall_segment("x", cx - half_w, cz - half_d, cz + half_d, WALL_T, wall_col)
			_add_wall_segment("x", cx + half_w, cz - half_d, cz + half_d, WALL_T, wall_col)
			if not enterable:
				_add_windows_on_wall("z", fz, cx - half_w, cx + half_w, WALL_T, 2)
		HouseFacing.MINUS_Z:
			var fz2 := cz - half_d
			_add_wall_segment("z", fz2, cx - half_w, cx + half_w, WALL_T, wall_col, cx, door_half)
			_add_trim_band("z", fz2, cx - half_w, cx + half_w, WALL_T)
			_add_wall_segment("z", cz + half_d, cx - half_w, cx + half_w, WALL_T, wall_col)
			_add_wall_segment("x", cx - half_w, cz - half_d, cz + half_d, WALL_T, wall_col)
			_add_wall_segment("x", cx + half_w, cz - half_d, cz + half_d, WALL_T, wall_col)
			if not enterable:
				_add_windows_on_wall("z", fz2, cx - half_w, cx + half_w, WALL_T, 2)
		HouseFacing.PLUS_X:
			var fx := cx + half_w
			_add_wall_segment("x", fx, cz - half_d, cz + half_d, WALL_T, wall_col, cz, door_half)
			_add_trim_band("x", fx, cz - half_d, cz + half_d, WALL_T)
			_add_wall_segment("x", cx - half_w, cz - half_d, cz + half_d, WALL_T, wall_col)
			_add_wall_segment("z", cz - half_d, cx - half_w, cx + half_w, WALL_T, wall_col)
			_add_wall_segment("z", cz + half_d, cx - half_w, cx + half_w, WALL_T, wall_col)
			if not enterable:
				_add_windows_on_wall("x", fx, cz - half_d, cz + half_d, WALL_T, 2)
		HouseFacing.MINUS_X:
			var fx2 := cx - half_w
			_add_wall_segment("x", fx2, cz - half_d, cz + half_d, WALL_T, wall_col, cz, door_half)
			_add_trim_band("x", fx2, cz - half_d, cz + half_d, WALL_T)
			_add_wall_segment("x", cx + half_w, cz - half_d, cz + half_d, WALL_T, wall_col)
			_add_wall_segment("z", cz - half_d, cx - half_w, cx + half_w, WALL_T, wall_col)
			_add_wall_segment("z", cz + half_d, cx - half_w, cx + half_w, WALL_T, wall_col)
			if not enterable:
				_add_windows_on_wall("x", fx2, cz - half_d, cz + half_d, WALL_T, 2)

	_add_roof(cx, cz, half_w, half_d, facing)
	_add_porch_at_front(cx, cz, facing, half_d, enterable)

	if enterable:
		_build_house_interior(cx, cz, facing, half_w, half_d)


func _build_house_interior(cx: float, cz: float, facing: HouseFacing, half_w: float, half_d: float) -> void:
	var inset := 0.4
	var ix0 := cx - half_w + inset
	var ix1 := cx + half_w - inset
	var iz0 := cz - half_d + inset
	var iz1 := cz + half_d - inset
	var iy1 := WALL_Y0 + WALL_H - 0.25

	_add_pavement(ix0, iz0, ix1, iz1, COL_INTERIOR_FLOOR)

	match facing:
		HouseFacing.PLUS_Z:
			_add_wall_segment("z", iz0, ix0, ix1, WALL_T, COL_INTERIOR_WALL)
			_add_wall_segment("x", ix0, iz0, iz1, WALL_T, COL_INTERIOR_WALL)
			_add_wall_segment("x", ix1, iz0, iz1, WALL_T, COL_INTERIOR_WALL)
		HouseFacing.MINUS_Z:
			_add_wall_segment("z", iz1, ix0, ix1, WALL_T, COL_INTERIOR_WALL)
			_add_wall_segment("x", ix0, iz0, iz1, WALL_T, COL_INTERIOR_WALL)
			_add_wall_segment("x", ix1, iz0, iz1, WALL_T, COL_INTERIOR_WALL)
		HouseFacing.PLUS_X:
			_add_wall_segment("x", ix0, iz0, iz1, WALL_T, COL_INTERIOR_WALL)
			_add_wall_segment("z", iz0, ix0, ix1, WALL_T, COL_INTERIOR_WALL)
			_add_wall_segment("z", iz1, ix0, ix1, WALL_T, COL_INTERIOR_WALL)
		HouseFacing.MINUS_X:
			_add_wall_segment("x", ix1, iz0, iz1, WALL_T, COL_INTERIOR_WALL)
			_add_wall_segment("z", iz0, ix0, ix1, WALL_T, COL_INTERIOR_WALL)
			_add_wall_segment("z", iz1, ix0, ix1, WALL_T, COL_INTERIOR_WALL)

	var cy := iy1
	_add_box(Vector3(ix0, cy, iz0), Vector3(ix1, cy + 0.15, iz1), COL_INTERIOR_WALL)


func _add_tree(tx: float, tz: float) -> void:
	_add_box(Vector3(tx - 0.2, WALL_Y0, tz - 0.2), Vector3(tx + 0.2, WALL_Y0 + 1.4, tz + 0.2), COL_TREE_TRUNK)
	_add_box(Vector3(tx - 0.9, WALL_Y0 + 1.2, tz - 0.9), Vector3(tx + 0.9, WALL_Y0 + 3.2, tz + 0.9), COL_TREE_CANOPY)


func _add_world_bounds() -> void:
	var hedge_h := 2.8
	var y1 := WALL_Y0 + hedge_h
	var t := 0.35
	_add_box(Vector3(-32.0, WALL_Y0, -14.0), Vector3(-31.0 + t, y1, 26.0), COL_HEDGE)
	_add_box(Vector3(31.0 - t, WALL_Y0, -14.0), Vector3(32.0, y1, 26.0), COL_HEDGE)
	_add_box(Vector3(-32.0, WALL_Y0, -14.0), Vector3(32.0, y1, -13.0 + t), COL_HEDGE)
	_add_box(Vector3(-32.0, WALL_Y0, 25.0 - t), Vector3(32.0, y1, 26.0), COL_HEDGE)


func _add_yards_and_lawns() -> void:
	# Grass lots between road and houses (not under pavement).
	_add_grass(-30.0, -14.0, 30.0, -8.0)
	_add_grass(-30.0, 11.0, 30.0, 26.0)
	_add_grass(-30.0, -8.0, -14.5, 11.0)
	_add_grass(14.5, -8.0, 30.0, 11.0)
	_add_grass(-30.0, -8.0, 30.0, -6.5)
	_add_grass(-30.0, 10.5, 30.0, 11.0)


func _add_street_and_culdesac() -> void:
	_add_yards_and_lawns()

	# Main street (south approach).
	_add_pavement(-3.2, 8.0, 3.2, 24.0, COL_ASPHALT)

	# Cul-de-sac bowl.
	_add_pavement(-13.5, -6.5, 13.5, 10.0, COL_ASPHALT)
	_add_pavement(-13.5, 6.0, -3.6, 10.0, COL_ASPHALT)
	_add_pavement(3.6, 6.0, 13.5, 10.0, COL_ASPHALT)

	# Sidewalks.
	var sw := 1.5
	_add_pavement(-3.2 - sw, 8.0, -3.2, 24.0, COL_SIDEWALK)
	_add_pavement(3.2, 8.0, 3.2 + sw, 24.0, COL_SIDEWALK)
	_add_pavement(-15.0, -4.0, -13.5, 8.0, COL_SIDEWALK)
	_add_pavement(13.5, -4.0, 15.0, 8.0, COL_SIDEWALK)

	# Curbs on top of pavement.
	var curb_y := PAVE_Y + PAVE_THICK
	var curb_t := 0.14
	_add_box(Vector3(-3.2, curb_y, 8.0), Vector3(-3.05, curb_y + curb_t, 24.0), COL_CURB)
	_add_box(Vector3(3.05, curb_y, 8.0), Vector3(3.2, curb_y + curb_t, 24.0), COL_CURB)


func _add_street_markings() -> void:
	var line_y := PAVE_Y + PAVE_THICK + 0.02
	var line_h := 0.025
	_add_box(Vector3(-0.14, line_y, 9.0), Vector3(0.14, line_y + line_h, 23.0), COL_YELLOW_LINE)
	for i in 8:
		var ang := float(i) / 8.0 * TAU + 0.2
		var rx := cos(ang) * 10.0
		var rz := sin(ang) * 5.5 + 2.0
		_add_box(Vector3(rx - 0.15, line_y, rz - 0.4), Vector3(rx + 0.15, line_y + line_h, rz + 0.4), COL_YELLOW_LINE)


func _add_park() -> void:
	var px0 := -22.0
	var px1 := -5.0
	var pz0 := 0.0
	var pz1 := 16.0
	_add_grass(px0, pz0, px1, pz1)

	_add_pavement(-5.0, 10.0, -3.2, 14.0, COL_SIDEWALK)

	var curb_y := PAVE_Y + PAVE_THICK
	var curb_t := 0.14
	_add_box(Vector3(px0, curb_y, pz0), Vector3(px1, curb_y + curb_t, pz0 + curb_t), COL_CURB)
	_add_box(Vector3(px0, curb_y, pz1 - curb_t), Vector3(px1, curb_y + curb_t, pz1), COL_CURB)
	_add_box(Vector3(px0, curb_y, pz0), Vector3(px0 + curb_t, curb_y + curb_t, pz1), COL_CURB)
	_add_box(Vector3(px1 - curb_t, curb_y, pz0), Vector3(px1, curb_y + curb_t, pz1), COL_CURB)

	_add_tree(-18.0, 4.0)
	_add_tree(-14.0, 10.0)
	_add_tree(-19.0, 13.0)
	_add_tree(-10.0, 6.0)
	_add_tree(-16.0, 7.5)
	_add_tree(-12.0, 13.0)

	_add_box(Vector3(-15.0, WALL_Y0, 5.0), Vector3(-12.0, WALL_Y0 + 0.45, 5.6), COL_BENCH)


func _add_houses() -> void:
	# Set back from the cul-de-sac asphalt.
	_add_house(0.0, -7.5, HouseFacing.PLUS_Z, true)
	_add_house(-14.0, 2.5, HouseFacing.PLUS_X, false)
	_add_house(14.0, 2.5, HouseFacing.MINUS_X, false)
	_add_house(-11.5, 9.0, HouseFacing.PLUS_Z, false)


func _build_neighborhood() -> void:
	_add_street_and_culdesac()
	_add_street_markings()
	_add_park()
	_add_houses()
	_add_world_bounds()


func get_player_spawn() -> Vector3:
	return Vector3(0.0, 1.0, 20.0)


func get_enemy_spawn() -> Vector3:
	return Vector3(-16.0, 1.0, 8.0)

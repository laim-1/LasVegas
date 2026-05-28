extends Node3D
class_name HorrorLevel
## Procedural cul-de-sac neighborhood: street, houses, park.

const GROUP_LEVEL := &"level_geometry"

# --- Palette ---
const COL_ASPHALT := Color(0.22, 0.24, 0.26)
const COL_SIDEWALK := Color(0.55, 0.56, 0.58)
const COL_GRASS := Color(0.28, 0.45, 0.25)
const COL_WALL_FAKE := Color(0.62, 0.58, 0.52)
const COL_WALL_REAL := Color(0.68, 0.55, 0.48)
const COL_ROOF := Color(0.25, 0.28, 0.35)
const COL_WINDOW := Color(0.2, 0.25, 0.32)
const COL_YELLOW_LINE := Color(0.85, 0.75, 0.2)
const COL_TREE_TRUNK := Color(0.35, 0.22, 0.12)
const COL_TREE_CANOPY := Color(0.2, 0.42, 0.22)
const COL_BENCH := Color(0.45, 0.3, 0.2)
const COL_INTERIOR_FLOOR := Color(0.4, 0.38, 0.35)
const COL_INTERIOR_WALL := Color(0.5, 0.48, 0.44)
const COL_CURB := Color(0.48, 0.49, 0.52)

const FLOOR_Y := -0.05
const FLOOR_THICK := 0.1
const WALL_Y0 := 0.0
const WALL_H := 5.0
const WALL_T := 0.25

# Facing: which world direction the front (door) wall faces.
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


func _add_flat_floor(x0: float, z0: float, x1: float, z1: float, color: Color) -> void:
	var y1 := FLOOR_Y + FLOOR_THICK
	_add_box(Vector3(x0, FLOOR_Y, z0), Vector3(x1, y1, z1), color)


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
	# axis "x": wall at constant x=fixed, spans z from span_a0 to span_a1, thickness along x = span_b
	# axis "z": wall at constant z=fixed, spans x from span_a0 to span_a1
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


func _add_roof(cx: float, cz: float, half_w: float, half_d: float) -> void:
	var y0 := WALL_Y0 + WALL_H
	var y1 := y0 + 0.35
	_add_box(
		Vector3(cx - half_w, y0, cz - half_d),
		Vector3(cx + half_w, y1, cz + half_d),
		COL_ROOF
	)


func _add_windows_on_wall(
		axis: String,
		fixed: float,
		span_a0: float,
		span_a1: float,
		depth: float,
		count: int
) -> void:
	var win_h := 1.2
	var win_w := 1.0
	var y0 := WALL_Y0 + 1.8
	var y1 := y0 + win_h
	var margin := 1.2
	var usable := span_a1 - span_a0 - margin * 2.0
	if count < 1 or usable <= win_w:
		return
	var step := usable / float(count)
	for i in count:
		var center_a := span_a0 + margin + step * (float(i) + 0.5)
		if axis == "z":
			_add_box(
				Vector3(center_a - win_w * 0.5, y0, fixed - depth * 0.5),
				Vector3(center_a + win_w * 0.5, y1, fixed + depth * 0.5),
				COL_WINDOW
			)
		else:
			_add_box(
				Vector3(fixed - depth * 0.5, y0, center_a - win_w * 0.5),
				Vector3(fixed + depth * 0.5, y1, center_a + win_w * 0.5),
				COL_WINDOW
			)


func _add_house(cx: float, cz: float, facing: HouseFacing, enterable: bool) -> void:
	var half_w := 4.0
	var half_d := 3.0
	var wall_col := COL_WALL_REAL if enterable else COL_WALL_FAKE
	var door_half := 0.6 if enterable else 0.0

	if enterable:
		_real_house_center = Vector3(cx, 0.0, cz)

	match facing:
		HouseFacing.PLUS_Z:
			# Door on +Z side (front at cz + half_d)
			var fz := cz + half_d
			_add_wall_segment("z", fz, cx - half_w, cx + half_w, WALL_T, wall_col, cx, door_half)
			_add_wall_segment("z", cz - half_d, cx - half_w, cx + half_w, WALL_T, wall_col)
			_add_wall_segment("x", cx - half_w, cz - half_d, cz + half_d, WALL_T, wall_col)
			_add_wall_segment("x", cx + half_w, cz - half_d, cz + half_d, WALL_T, wall_col)
			if not enterable:
				_add_windows_on_wall("z", fz, cx - half_w, cx + half_w, WALL_T, 2)
		HouseFacing.MINUS_Z:
			var fz := cz - half_d
			_add_wall_segment("z", fz, cx - half_w, cx + half_w, WALL_T, wall_col, cx, door_half)
			_add_wall_segment("z", cz + half_d, cx - half_w, cx + half_w, WALL_T, wall_col)
			_add_wall_segment("x", cx - half_w, cz - half_d, cz + half_d, WALL_T, wall_col)
			_add_wall_segment("x", cx + half_w, cz - half_d, cz + half_d, WALL_T, wall_col)
			if not enterable:
				_add_windows_on_wall("z", fz, cx - half_w, cx + half_w, WALL_T, 2)
		HouseFacing.PLUS_X:
			var fx := cx + half_w
			_add_wall_segment("x", fx, cz - half_d, cz + half_d, WALL_T, wall_col, cz, door_half)
			_add_wall_segment("x", cx - half_w, cz - half_d, cz + half_d, WALL_T, wall_col)
			_add_wall_segment("z", cz - half_d, cx - half_w, cx + half_w, WALL_T, wall_col)
			_add_wall_segment("z", cz + half_d, cx - half_w, cx + half_w, WALL_T, wall_col)
			if not enterable:
				_add_windows_on_wall("x", fx, cz - half_d, cz + half_d, WALL_T, 2)
		HouseFacing.MINUS_X:
			var fx := cx - half_w
			_add_wall_segment("x", fx, cz - half_d, cz + half_d, WALL_T, wall_col, cz, door_half)
			_add_wall_segment("x", cx + half_w, cz - half_d, cz + half_d, WALL_T, wall_col)
			_add_wall_segment("z", cz - half_d, cx - half_w, cx + half_w, WALL_T, wall_col)
			_add_wall_segment("z", cz + half_d, cx - half_w, cx + half_w, WALL_T, wall_col)
			if not enterable:
				_add_windows_on_wall("x", fx, cz - half_d, cz + half_d, WALL_T, 2)

	_add_roof(cx, cz, half_w + 0.15, half_d + 0.15)

	if enterable:
		_build_house_interior(cx, cz, facing, half_w, half_d)


func _build_house_interior(cx: float, cz: float, facing: HouseFacing, half_w: float, half_d: float) -> void:
	var inset := 0.35
	var ix0 := cx - half_w + inset
	var ix1 := cx + half_w - inset
	var iz0 := cz - half_d + inset
	var iz1 := cz + half_d - inset
	var iy1 := WALL_Y0 + WALL_H - 0.2

	_add_flat_floor(ix0, iz0, ix1, iz1, COL_INTERIOR_FLOOR)

	# Interior walls (leave front open where door is)
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

	# Low ceiling
	var cy := iy1
	_add_box(Vector3(ix0, cy, iz0), Vector3(ix1, cy + 0.15, iz1), COL_INTERIOR_WALL)


func _add_tree(tx: float, tz: float) -> void:
	_add_box(Vector3(tx - 0.2, WALL_Y0, tz - 0.2), Vector3(tx + 0.2, WALL_Y0 + 1.4, tz + 0.2), COL_TREE_TRUNK)
	_add_box(Vector3(tx - 0.9, WALL_Y0 + 1.2, tz - 0.9), Vector3(tx + 0.9, WALL_Y0 + 3.2, tz + 0.9), COL_TREE_CANOPY)


func _add_world_bounds() -> void:
	var y1 := WALL_Y0 + WALL_H
	var t := WALL_T
	# Perimeter fence so player cannot walk off the map.
	_add_box(Vector3(-32.0, WALL_Y0, -14.0), Vector3(-31.0, y1, 26.0), COL_WALL_FAKE)
	_add_box(Vector3(31.0, WALL_Y0, -14.0), Vector3(32.0, y1, 26.0), COL_WALL_FAKE)
	_add_box(Vector3(-32.0, WALL_Y0, -14.0), Vector3(32.0, y1, -13.0), COL_WALL_FAKE)
	_add_box(Vector3(-32.0, WALL_Y0, 25.0), Vector3(32.0, y1, 26.0), COL_WALL_FAKE)


func _add_street_and_culdesac() -> void:
	# Base grass for whole neighborhood.
	_add_flat_floor(-30.0, -14.0, 30.0, 26.0, COL_GRASS)

	# Main street (south approach) — z 8..24, 6m wide.
	_add_flat_floor(-3.0, 8.0, 3.0, 24.0, COL_ASPHALT)

	# Cul-de-sac bowl — wide asphalt loop north of main street.
	_add_flat_floor(-13.0, -6.0, 13.0, 10.0, COL_ASPHALT)
	# Connect arms to main street.
	_add_flat_floor(-13.0, 6.0, -3.5, 10.0, COL_ASPHALT)
	_add_flat_floor(3.5, 6.0, 13.0, 10.0, COL_ASPHALT)

	# Sidewalks along main street.
	var sw := 1.4
	_add_flat_floor(-3.0 - sw, 8.0, -3.0, 24.0, COL_SIDEWALK)
	_add_flat_floor(3.0, 8.0, 3.0 + sw, 24.0, COL_SIDEWALK)

	# Sidewalk around cul-de-sac outer edge (partial).
	_add_flat_floor(-14.4, -4.0, -13.0, 8.0, COL_SIDEWALK)
	_add_flat_floor(13.0, -4.0, 14.4, 8.0, COL_SIDEWALK)

	# Curbs (thin strips).
	var curb_t := 0.12
	_add_box(Vector3(-3.0, FLOOR_Y, 8.0), Vector3(-2.85, FLOOR_Y + curb_t, 24.0), COL_CURB)
	_add_box(Vector3(2.85, FLOOR_Y, 8.0), Vector3(3.0, FLOOR_Y + curb_t, 24.0), COL_CURB)


func _add_street_markings() -> void:
	var line_y := FLOOR_Y + FLOOR_THICK + 0.01
	var line_h := 0.02
	# Center line on main street.
	_add_box(Vector3(-0.12, line_y, 9.0), Vector3(0.12, line_y + line_h, 23.0), COL_YELLOW_LINE)
	# Cul-de-sac ring hint (broken segments).
	for i in 8:
		var ang := float(i) / 8.0 * TAU + 0.2
		var rx := cos(ang) * 10.0
		var rz := sin(ang) * 5.5 + 2.0
		_add_box(Vector3(rx - 0.15, line_y, rz - 0.4), Vector3(rx + 0.15, line_y + line_h, rz + 0.4), COL_YELLOW_LINE)


func _add_park() -> void:
	# Park block northwest.
	var px0 := -22.0
	var px1 := -5.0
	var pz0 := 0.0
	var pz1 := 16.0
	_add_flat_floor(px0, pz0, px1, pz1, COL_GRASS)

	# Sidewalk from main street to park.
	_add_flat_floor(-5.0, 10.0, -3.0, 14.0, COL_SIDEWALK)

	# Park border curb.
	var curb_t := 0.12
	_add_box(Vector3(px0, FLOOR_Y, pz0), Vector3(px1, FLOOR_Y + curb_t, pz0 + curb_t), COL_CURB)
	_add_box(Vector3(px0, FLOOR_Y, pz1 - curb_t), Vector3(px1, FLOOR_Y + curb_t, pz1), COL_CURB)
	_add_box(Vector3(px0, FLOOR_Y, pz0), Vector3(px0 + curb_t, FLOOR_Y + curb_t, pz1), COL_CURB)
	_add_box(Vector3(px1 - curb_t, FLOOR_Y, pz0), Vector3(px1, FLOOR_Y + curb_t, pz1), COL_CURB)

	# Trees.
	_add_tree(-18.0, 4.0)
	_add_tree(-14.0, 10.0)
	_add_tree(-19.0, 13.0)
	_add_tree(-10.0, 6.0)
	_add_tree(-16.0, 7.5)
	_add_tree(-12.0, 13.0)

	# Bench.
	_add_box(Vector3(-15.0, WALL_Y0, 5.0), Vector3(-12.0, WALL_Y0 + 0.45, 5.6), COL_BENCH)


func _add_houses() -> void:
	# Enterable house at cul-de-sac dead end (north) — door faces south (+Z) toward approach.
	_add_house(0.0, -4.0, HouseFacing.PLUS_Z, true)

	# Fake houses on the loop.
	_add_house(-11.0, 5.0, HouseFacing.PLUS_X, false)
	_add_house(11.0, 5.0, HouseFacing.MINUS_X, false)
	_add_house(-9.0, 8.0, HouseFacing.PLUS_Z, false)


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

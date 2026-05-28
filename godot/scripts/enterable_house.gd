extends RefCounted
class_name EnterableHouseBuilder
## Two-story enterable home interior + shell (built from HorrorLevel).

const HALF_W := 5.0
const HALF_D := 4.0
const INSET := 0.35
const EXT_H := 6.2
const F1_H := 2.75
const F2_SLAB := 2.85
const F2_H := 2.55
const INT_T := 0.14
const DOOR_HALF := 0.75

const COL_WALL_EXT := Color(0.72, 0.62, 0.52)
const COL_WALL_INT := Color(0.5, 0.48, 0.44)
const COL_FLOOR := Color(0.4, 0.38, 0.35)
const COL_FLOOR2 := Color(0.44, 0.4, 0.36)
const COL_CEIL := Color(0.52, 0.5, 0.46)
const COL_STAIR := Color(0.48, 0.45, 0.42)
const COL_RAIL := Color(0.55, 0.52, 0.48)
const COL_COUNTER := Color(0.58, 0.56, 0.54)
const COL_TUB := Color(0.62, 0.64, 0.68)


static func build(level: HorrorLevel, cx: float, cz: float, facing: HorrorLevel.HouseFacing) -> void:
	var y0 := HorrorLevel.GROUND_TOP
	var y_f1_ceil := y0 + F1_H
	var y_f2 := y0 + F2_SLAB
	var y_f2_ceil := y_f2 + F2_H
	var y_ext_top := y0 + EXT_H

	var ix0 := cx - HALF_W + INSET
	var ix1 := cx + HALF_W - INSET
	var iz0 := cz - HALF_D + INSET
	var iz1 := cz + HALF_D - INSET

	# Room bounds (world XZ). Front = +Z (iz1), back = -Z (iz0).
	var x_stair0 := ix0
	var x_stair1 := ix0 + 1.15
	var x_hall1 := ix0 + 2.5
	var x_div := cx + 0.55
	var z_foyer_back := iz1 - 3.0
	var z_back_div := cz - 2.5

	level._real_house_center = Vector3(cx, 0.0, cz)

	_build_exterior_shell(level, cx, cz, facing, y0, y_ext_top)
	_build_porch(level, cx, cz, facing, y0)

	# --- Floor 1 slabs ---
	_add_slab(level, ix0, iz0, ix1, iz1, y0, COL_FLOOR)
	_add_slab(level, x_div, z_foyer_back, ix1, iz1, y0 + 0.002, Color(0.42, 0.4, 0.37))  # living
	_add_slab(level, x_stair1, z_foyer_back, x_div, iz1, y0 + 0.002, Color(0.38, 0.36, 0.34))  # foyer
	_add_slab(level, x_hall1, z_back_div, x_div, z_foyer_back, y0 + 0.002, COL_FLOOR)
	_add_slab(level, x_div, z_back_div, ix1, z_foyer_back, y0 + 0.002, Color(0.4, 0.38, 0.35))  # dining
	_add_slab(level, x_div, iz0, ix1, z_back_div, y0 + 0.002, Color(0.39, 0.37, 0.34))  # kitchen

	# --- Floor 1 walls ---
	_add_wall_z(level, iz0, ix0, ix1, y0, y_f1_ceil, INT_T, COL_WALL_INT)
	_add_wall_x(level, ix0, iz0, iz1, y0, y_f1_ceil, INT_T, COL_WALL_INT)
	_add_wall_x(level, ix1, iz0, iz1, y0, y_f1_ceil, INT_T, COL_WALL_INT)
	# Front: open (porch door); sides of entry only
	_add_wall_z(level, iz1, ix0, x_stair0, y0, y_f1_ceil, INT_T, COL_WALL_INT)
	_add_wall_z(level, iz1, x_stair1, ix1, y0, y_f1_ceil, INT_T, COL_WALL_INT)

	_add_wall_z(level, z_foyer_back, x_hall1, x_div, y0, y_f1_ceil, INT_T, COL_WALL_INT)
	_add_wall_z(level, z_foyer_back, x_div, ix1, y0, y_f1_ceil, INT_T, COL_WALL_INT, cx + 2.0, 1.0)
	_add_wall_z(level, z_back_div, x_hall1, ix1, y0, y_f1_ceil, INT_T, COL_WALL_INT, cx + 1.5, 1.0)
	_add_wall_x(level, x_div, z_back_div, iz1, y0, y_f1_ceil, INT_T, COL_WALL_INT, cz - 0.5, 1.2)
	_add_wall_x(level, x_hall1, iz0, z_foyer_back, y0, y_f1_ceil, INT_T, COL_WALL_INT)
	_add_wall_x(level, x_stair1, iz0, iz1, y0, y_f1_ceil, INT_T, COL_WALL_INT)

	# Under-stair closet
	_add_wall_z(level, z_back_div, x_stair0, x_stair1, y0, y_f1_ceil, INT_T, COL_WALL_INT)
	_add_wall_z(level, iz0 + 1.2, x_stair0, x_stair1, y0, y_f1_ceil, INT_T, COL_WALL_INT)

	# --- Floor 1 ceiling (stairwell opening left open) ---
	_add_ceil_z(level, z_foyer_back, x_stair1, ix1, y_f1_ceil, COL_CEIL)
	_add_ceil_z(level, z_foyer_back, x_stair1, x_div, y_f1_ceil, COL_CEIL)
	_add_ceil_z(level, z_back_div, x_hall1, ix1, y_f1_ceil, COL_CEIL)
	_add_slab(level, x_div, z_back_div, ix1, z_foyer_back, y_f1_ceil - 0.08, COL_CEIL, 0.1)
	_add_ceil_z(level, iz0, x_hall1, ix1, y_f1_ceil, COL_CEIL)
	_add_ceil_x(level, x_hall1, z_back_div, z_foyer_back, y_f1_ceil, COL_CEIL)
	_add_ceil_x(level, x_div, z_back_div, z_foyer_back, y_f1_ceil, COL_CEIL)
	_add_ceil_x(level, ix1, z_back_div, iz1, y_f1_ceil, COL_CEIL)

	# --- Stairs (west, toward back then landing) ---
	_build_stairs(level, x_stair0, x_stair1, iz1 - 0.5, iz0 + 1.5, y0, y_f2)

	# --- Floor 2 slabs (open stairwell on west) ---
	_add_slab(level, x_div, z_foyer_back, ix1, iz1, y_f2, COL_FLOOR2)  # master
	_add_slab(level, x_div, iz0, ix1, z_back_div, y_f2, COL_FLOOR2)  # bed 2
	_add_slab(level, ix0, iz0, x_hall1, z_back_div, y_f2, COL_FLOOR2)  # study
	_add_slab(level, x_hall1, z_back_div, x_div, z_foyer_back, y_f2, COL_FLOOR2)  # bath / hall
	_add_slab(level, x_stair0, iz0, x_stair1, iz0 + 1.6, y_f2, COL_FLOOR2)  # stair landing (back)

	# --- Floor 2 walls ---
	_add_wall_z(level, iz0, ix0, ix1, y_f2, y_f2_ceil, INT_T, COL_WALL_INT)
	_add_wall_x(level, ix0, iz0, iz1, y_f2, y_f2_ceil, INT_T, COL_WALL_INT)
	_add_wall_x(level, ix1, iz0, iz1, y_f2, y_f2_ceil, INT_T, COL_WALL_INT)
	_add_wall_z(level, iz1, x_div, ix1, y_f2, y_f2_ceil, INT_T, COL_WALL_INT)
	_add_wall_z(level, iz1, ix0, x_stair0, y_f2, y_f2_ceil, INT_T, COL_WALL_INT)

	_add_wall_z(level, z_foyer_back, x_stair1, ix1, y_f2, y_f2_ceil, INT_T, COL_WALL_INT)
	_add_wall_z(level, z_back_div, x_hall1, ix1, y_f2, y_f2_ceil, INT_T, COL_WALL_INT)
	_add_wall_x(level, x_hall1, iz0, iz1, y_f2, y_f2_ceil, INT_T, COL_WALL_INT)
	_add_wall_x(level, x_div, z_back_div, iz1, y_f2, y_f2_ceil, INT_T, COL_WALL_INT, cz - 0.3, 0.9)
	_add_wall_x(level, x_stair1, iz0, z_foyer_back, y_f2, y_f2_ceil, INT_T, COL_WALL_INT, cz - 1.0, 0.9)
	_add_wall_x(level, ix0 + 2.0, iz0, z_back_div, y_f2, y_f2_ceil, INT_T, COL_WALL_INT, cz - 1.8, 0.9)

	# Master (east front) door gap on hall wall
	_add_wall_x(level, x_stair1, z_foyer_back, iz1, y_f2, y_f2_ceil, INT_T, COL_WALL_INT, cz - 0.2, 0.9)

	# --- Floor 2 ceiling ---
	_add_slab(level, ix0, iz0, ix1, iz1, y_f2_ceil, COL_CEIL, 0.12)

	# --- Stair railings (open to living below) ---
	var rail_h := 0.92
	_add_wall_z(level, iz1 - 0.5, x_stair1, ix1, y_f2, y_f2 + rail_h, 0.1, COL_RAIL)
	_add_wall_x(level, x_stair1, iz1 - 0.5, z_foyer_back, y_f2, y_f2 + rail_h, 0.1, COL_RAIL)
	_add_wall_x(level, ix1 - 0.1, iz1 - 0.5, z_foyer_back, y_f2, y_f2 + rail_h, 0.08, COL_RAIL)

	# --- Props ---
	level.add_box(
		Vector3(x_div + 0.2, y0, iz0 + 0.2),
		Vector3(ix1 - 0.2, y0 + 0.9, iz0 + 0.7),
		COL_COUNTER
	)
	level.add_box(
		Vector3(x_div + 0.3, y_f2, z_back_div + 0.3),
		Vector3(x_div + 1.8, y_f2 + 0.5, z_back_div + 1.4),
		COL_TUB
	)


static func _build_exterior_shell(
		level: HorrorLevel,
		cx: float,
		cz: float,
		facing: HorrorLevel.HouseFacing,
		y0: float,
		y_top: float
) -> void:
	var hw := HALF_W
	var hd := HALF_D
	level._add_house_lawn(cx, cz, hw, hd, facing)
	level._add_house_foundation(cx, cz, hw, hd)

	if facing != HorrorLevel.HouseFacing.PLUS_Z:
		push_warning("Enterable house only supports PLUS_Z facing")
		return

	var fz := cz + hd
	level._add_wall_segment_height("z", fz, cx - hw, cx + hw, HorrorLevel.WALL_T, y0, y_top, COL_WALL_EXT, cx, DOOR_HALF)
	level._add_trim_band_height("z", fz, cx - hw, cx + hw, HorrorLevel.WALL_T, y_top - 0.22, y_top)
	level._add_wall_segment_height("z", cz - hd, cx - hw, cx + hw, HorrorLevel.WALL_T, y0, y_top, COL_WALL_EXT)
	level._add_wall_segment_height("x", cx - hw, cz - hd, cz + hd, HorrorLevel.WALL_T, y0, y_top, COL_WALL_EXT)
	level._add_wall_segment_height("x", cx + hw, cz - hd, cz + hd, HorrorLevel.WALL_T, y0, y_top, COL_WALL_EXT)

	_add_exterior_windows(level, cx, cz, hw, hd, y0)
	level._add_roof_tall(cx, cz, hw, hd, facing, y_top)


static func _add_exterior_windows(level: HorrorLevel, cx: float, cz: float, hw: float, hd: float, y0: float) -> void:
	var fz := cz + hd
	var bz := cz - hd
	# Living / master — large front windows
	for y_off in [1.0, 3.2]:
		level.add_box(
			Vector3(cx + 1.5, y0 + y_off, fz - 0.12),
			Vector3(cx + 4.2, y0 + y_off + 1.4, fz + 0.12),
			HorrorLevel.COL_WINDOW
		)
	# Kitchen / bed2 — back
	level.add_box(
		Vector3(cx + 1.0, y0 + 1.0, bz - 0.12),
		Vector3(cx + 4.0, y0 + 2.4, bz + 0.12),
		HorrorLevel.COL_WINDOW
	)
	level.add_box(
		Vector3(cx + 1.0, y0 + 3.2, bz - 0.12),
		Vector3(cx + 3.5, y0 + 4.5, bz + 0.12),
		HorrorLevel.COL_WINDOW
	)
	# Study — west
	var wx := cx - hw
	level.add_box(
		Vector3(wx - 0.12, y0 + 3.0, cz - 2.5),
		Vector3(wx + 0.12, y0 + 4.3, cz + 0.5),
		HorrorLevel.COL_WINDOW
	)


static func _build_porch(level: HorrorLevel, cx: float, cz: float, _facing: HorrorLevel.HouseFacing, y0: float) -> void:
	var fz := cz + HALF_D
	var step_h := 0.16
	var plat_d := 1.25
	var plat_w := 2.8
	level.add_box(
		Vector3(cx - plat_w * 0.5, y0 - step_h, fz),
		Vector3(cx + plat_w * 0.5, y0, fz + step_h),
		HorrorLevel.COL_FOUNDATION
	)
	level.add_box(
		Vector3(cx - plat_w * 0.5, y0, fz + step_h),
		Vector3(cx + plat_w * 0.5, y0 + 0.1, fz + step_h + plat_d),
		HorrorLevel.COL_SIDEWALK
	)
	level.add_box(
		Vector3(cx - 0.5, y0 + 0.1, fz - 0.08),
		Vector3(cx + 0.5, y0 + 2.2, fz + 0.12),
		HorrorLevel.COL_DOOR
	)


static func _build_stairs(
		level: HorrorLevel,
		x0: float,
		x1: float,
		z_front: float,
		z_back: float,
		y_bottom: float,
		y_top: float
) -> void:
	var steps := 15
	var rise := (y_top - y_bottom) / float(steps)
	var run := (z_front - z_back) / float(steps)
	for i in steps:
		var y_s := y_bottom + rise * float(i)
		var y_e := y_bottom + rise * float(i + 1)
		var z_s := z_front - run * float(i)
		var z_e := z_front - run * float(i + 1)
		level.add_box(Vector3(x0, y_s, z_e), Vector3(x1, y_e, z_s), COL_STAIR)


static func _add_slab(
		level: HorrorLevel,
		x0: float,
		z0: float,
		x1: float,
		z1: float,
		y: float,
		color: Color,
		thick: float = 0.08
) -> void:
	level.add_box(Vector3(x0, y, z0), Vector3(x1, y + thick, z1), color)


static func _add_ceil_z(
		level: HorrorLevel, z: float, x0: float, x1: float, y: float, color: Color
) -> void:
	_add_slab(level, x0, z - INT_T, x1, z, y - 0.08, color, 0.1)


static func _add_ceil_x(
		level: HorrorLevel, x: float, z0: float, z1: float, y: float, color: Color
) -> void:
	_add_slab(level, x - INT_T, z0, x, z1, y - 0.08, color, 0.1)


static func _add_wall_z(
		level: HorrorLevel,
		z: float,
		x0: float,
		x1: float,
		y0: float,
		y1: float,
		thick: float,
		color: Color,
		door_x: float = INF,
		door_half: float = 0.0
) -> void:
	level._add_wall_segment_height("z", z, x0, x1, thick, y0, y1, color, door_x, door_half)


static func _add_wall_x(
		level: HorrorLevel,
		x: float,
		z0: float,
		z1: float,
		y0: float,
		y1: float,
		thick: float,
		color: Color,
		door_z: float = INF,
		door_half: float = 0.0
) -> void:
	level._add_wall_segment_height("x", x, z0, z1, thick, y0, y1, color, door_z, door_half)

extends Node3D
class_name HorrorLevel
## Builds the prototype room from the same AABB layout as the C++ version.

const GROUP_LEVEL := &"level_geometry"


func _ready() -> void:
	_build_prototype_room()


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


func _build_prototype_room() -> void:
	var min_x := -5.0
	var max_x := 5.0
	var min_z := -5.0
	var max_z := 5.0
	var floor_y0 := -0.1
	var floor_y1 := 0.0
	var wall_y0 := 0.0
	var wall_y1 := 3.0
	var t := 0.2

	_add_box(Vector3(min_x, floor_y0, min_z), Vector3(max_x, floor_y1, max_z), Color(0.62, 0.64, 0.68))
	_add_box(Vector3(min_x, wall_y0, min_z - t), Vector3(max_x, wall_y1, min_z), Color(0.48, 0.5, 0.55))
	_add_box(Vector3(min_x, wall_y0, max_z), Vector3(max_x, wall_y1, max_z + t), Color(0.48, 0.5, 0.55))
	_add_box(Vector3(min_x - t, wall_y0, min_z), Vector3(min_x, wall_y1, max_z), Color(0.48, 0.5, 0.55))
	_add_box(Vector3(max_x, wall_y0, min_z), Vector3(max_x + t, wall_y1, max_z), Color(0.48, 0.5, 0.55))
	_add_box(Vector3(-1.6, wall_y0, -2.0), Vector3(1.6, wall_y1, -1.4), Color(0.42, 0.44, 0.5))
	_add_box(Vector3(-3.5, wall_y0, 1.4), Vector3(-2.9, wall_y1, 3.5), Color(0.42, 0.44, 0.5))


func get_player_spawn() -> Vector3:
	return Vector3(0.0, 1.0, 0.0)


func get_enemy_spawn() -> Vector3:
	return Vector3(0.0, 1.0, -3.2)

class_name SlashEffect
extends MeshInstance3D

var lifetime: float = 0.15
var _timer: float = 0.0
var _material: StandardMaterial3D

func setup(attack_range: float, angle_degrees: float, color: Color = Color(1, 1, 1, 0.85)):
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var segments = 12
	var half_angle = deg_to_rad(angle_degrees / 2.0)

	for i in range(segments):
		var a0 = lerp(-half_angle, half_angle, float(i) / segments)
		var a1 = lerp(-half_angle, half_angle, float(i + 1) / segments)
		var p0 = Vector3(sin(a0), 0, -cos(a0)) * attack_range
		var p1 = Vector3(sin(a1), 0, -cos(a1)) * attack_range
		st.add_vertex(Vector3.ZERO)
		st.add_vertex(p0)
		st.add_vertex(p1)

	mesh = st.commit()

	_material = StandardMaterial3D.new()
	_material.albedo_color = color
	_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material_override = _material

func _process(delta):
	_timer += delta
	var t = _timer / lifetime
	if _material:
		_material.albedo_color.a = lerp(0.85, 0.0, t)
	if _timer >= lifetime:
		queue_free()

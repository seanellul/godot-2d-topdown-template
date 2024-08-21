extends BaseState
class_name StateMaterial

@export var mesh_instance: MeshInstance3D = null
@export var material: StandardMaterial3D = null

func enter():
	if mesh_instance:
		mesh_instance.set_surface_override_material(0, material)

func exit():
	if mesh_instance and mesh_instance.get_surface_override_material_count() > 0:
		mesh_instance.set_surface_override_material(0, null)

extends Camera2D

func _ready() -> void:
	SceneManager.load_start.connect(_disable_camera)
	SceneManager.load_complete.connect(_enable_camera)

func _disable_camera(loading_screen):
	position_smoothing_enabled = false

func _enable_camera(loaded_scene:Node):
	position_smoothing_enabled = true

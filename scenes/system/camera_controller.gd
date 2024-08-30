extends Camera2D

func _ready() -> void:
	Globals.transfer_start.connect(_disable_camera)
	Globals.transfer_complete.connect(_enable_camera)

func _disable_camera():
	position_smoothing_enabled = false

func _enable_camera():
	position_smoothing_enabled = true

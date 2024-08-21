class_name StartScreen extends Control

const template_version: String = "0.1"

@onready var version_num: Label = %VersionNum
func _ready() -> void:
	version_num.text = "v%s" % template_version

func _on_start_button_up() -> void:
	SceneManager.swap_scenes(Const.LEVEL.GAME_START, get_tree().root, self, Const.TRANSITION.FADE_TO_WHITE)	

func _on_settings_button_up() -> void:
	Globals.open_settings_menu()

func _on_quit_button_up() -> void:
	get_tree().quit()

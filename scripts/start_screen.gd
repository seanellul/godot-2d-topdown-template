class_name StartScreen extends Control

const template_version: String = "0.1"

var level_to_load
var user_prefs: UserPrefs

@onready var version_num: Label = %VersionNum
func _ready() -> void:
	version_num.text = "v%s" % template_version
	user_prefs = UserPrefs.load_or_create()
	TranslationServer.set_locale(user_prefs.language)

func _on_start_button_up() -> void:
	SceneManager.swap_scenes(Const.LEVEL.GAME_START, get_tree().root, self, Const.TRANSITION.FADE_TO_WHITE)	

func _on_continue_button_up() -> void:
	level_to_load = DataManager.game_data.current_level
	_on_start_button_up()

func _on_settings_button_up() -> void:
	Globals.open_settings_menu()

func _on_quit_button_up() -> void:
	get_tree().quit()

func get_data():
	return level_to_load
	

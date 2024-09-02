class_name StartScreen extends Control

const template_version: String = "0.1"

var level_to_load
var user_prefs: UserPrefs

@onready var version_num: Label = %VersionNum
@onready var continueButton: Button = %Continue

func _ready() -> void:
	version_num.text = "v%s" % template_version
	user_prefs = UserPrefs.load_or_create()
	_check_continue()
	TranslationServer.set_locale(user_prefs.language)

func _check_continue():
	if SaveFileManager.save_file_exists():
		continueButton.visible = true

func _on_new_game_button_up() -> void:
	DataManager.reset_game_data()
	SceneManager.swap_scenes(Const.LEVEL.GAME_START, get_tree().root, self, Const.TRANSITION.FADE_TO_WHITE)	

func _on_continue_button_up() -> void:
	DataManager.load_game_data()
	level_to_load = DataManager.game_data.player_data.level
	SceneManager.swap_scenes(Const.LEVEL.GAME_START, get_tree().root, self, Const.TRANSITION.FADE_TO_WHITE)	

func _on_settings_button_up() -> void:
	Globals.open_settings_menu()

func _on_quit_button_up() -> void:
	get_tree().quit()

func get_data():
	return level_to_load

extends Node

@onready var SFX_BUS_ID = AudioServer.get_bus_index("SFX")
@onready var MUSIC_BUS_ID = AudioServer.get_bus_index("Music")

var user_prefs:UserPrefs

var settings_menu_scene:PackedScene = preload("res://scenes/menus/settings_menu.tscn")
var settings_menu = null

@warning_ignore("unused_signal")
signal player_action(node, action, direction)
@warning_ignore("unused_signal")
signal enemy_hurt
@warning_ignore("unused_signal")
signal transfer_start
@warning_ignore("unused_signal")
signal transfer_complete

func _ready():
	user_prefs = UserPrefs.load_or_create()
	AudioServer.set_bus_volume_db(SFX_BUS_ID, linear_to_db(user_prefs.sfx_volume))
	AudioServer.set_bus_mute(SFX_BUS_ID, user_prefs.sfx_volume < .05)
	AudioServer.set_bus_volume_db(MUSIC_BUS_ID, linear_to_db(user_prefs.music_volume))
	AudioServer.set_bus_mute(MUSIC_BUS_ID, user_prefs.music_volume < .05)

enum GLOBAL_STATE {
	MAIN_MENU,
	GAMEPLAY,
	CONVERSATION,
	PAUSED
}

const LANGUAGES:Array = [
	"en",
	"it"	
]

func get_selected_language() -> String:
	var s:String = user_prefs.language
	if not s.is_empty():
		return s
	return LANGUAGES[0]

func open_settings_menu():
	if not settings_menu:
		settings_menu = settings_menu_scene.instantiate()
		get_tree().root.add_child(settings_menu)
	else:
		push_warning('settings menu already exists in this scene')

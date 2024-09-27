extends Node

@onready var SFX_BUS_ID = AudioServer.get_bus_index("SFX")
@onready var MUSIC_BUS_ID = AudioServer.get_bus_index("Music")

var user_prefs:UserPrefs

var settings_menu_scene:PackedScene = preload("res://scenes/menus/settings_menu.tscn")
var settings_menu = null

@warning_ignore("unused_signal")
signal enemy_hurt
@warning_ignore("unused_signal")
signal transfer_start
@warning_ignore("unused_signal")
signal transfer_complete
@warning_ignore("unused_signal")
signal player_added_to_scene(player: PlayerEntity)
@warning_ignore("unused_signal")
signal state_machine_initialized(state_machine: StateMachine)

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

func get_player(id: int):
	if GameManager.gm and GameManager.gm.current_level and GameManager.gm.current_level.players.size() > 0:
		return GameManager.gm.current_level.players[id - 1]
	elif is_inside_tree():
		return get_tree().get_first_node_in_group(Const.GROUP.PLAYER)
	else:
		return null

func get_destination(destination_name: String):
	var transfers: Array[Node] = get_tree().get_nodes_in_group(Const.GROUP.DESTINATION)
	var found = transfers.filter(func(t): return t.name == destination_name)
	var destination = found[0] if found.size() > 0 else null
	return destination
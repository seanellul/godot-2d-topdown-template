class_name Const extends Node

const SAVE_FILE_BASE_PATH := "user://save"

const MENU = {
	TITLE_SCREEN = "res://scenes/menus/start_screen.gd"
}

const LEVEL = {
	GAME_START = "res://scenes/levels/Level01.tscn"
}

const TRANSITION = {
	FADE_TO_BLACK = "fade_to_black",
	FADE_FROM_BLACK = "fade_from_black",
	FADE_TO_WHITE = "fade_to_white",
	FADE_FROM_WHITE = "fade_from_white",
}

const DIRECTION = {
	DOWN = "down",
	LEFT = "left",
	RIGHT = "right",
	UP = "up",
}

const DIR_BIT = {
	Vector2(0, 1): 1 << 0, #down
	Vector2(-1, 0): 1 << 1, #left
	Vector2(1, 0): 1 << 2, #right
	Vector2(0, -1): 1 << 3, #up
	Vector2(-1, -1): 1 << 4, #up left
	Vector2(0, 0): 1 << 7, #down right
}

const GROUP = {
	PLAYER = "player",
	ENEMY = "enemy",
	SAVE = "save",
	FLASH = "flash"
}

const ANIM = {
	JUMP = "jump",
	WALK = "walk",
	IDLE = "idle",
	RECALL = "recall",
	INTERACT = "interact",
	RUN = "run",
	ATTACK = "attack",
	CHARGING = "charging"
}

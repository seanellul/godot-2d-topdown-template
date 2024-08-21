class_name Const extends Node

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
	UP = "up"
}

const DIR_NAME = {
	Vector3(0, 0, 1): DIRECTION.DOWN,
	Vector3(-1, 0, 0): DIRECTION.LEFT,
	Vector3(1, 0, 0): DIRECTION.RIGHT,
	Vector3(0, 0, -1): DIRECTION.UP,
}

const DIR_BIT = {
	Vector3(0, 0, 1): 1 << 0,
	Vector3(-1, 0, 0): 1 << 1,
	Vector3(1, 0, 0): 1 << 2,
	Vector3(0, 0, -1): 1 << 3,
}

const GROUP = {
	PLAYER = "player",
	ENEMY = "enemy",
	SAVE = "save"
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

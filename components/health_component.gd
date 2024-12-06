@icon("res://icons/HealthComponent.svg")
extends Node2D
class_name HealthComponent

@export_group("Health")
@export var max_hp := 20 ## The total hp of the entity. If the entity has health_bar assigned, it is the value that corresponds to the health_bar completely full.
@export var recovery_time := 1.0 ## The waiting time before changing the HP again.
@export var health_bar: PackedScene ## A PackedScene that displays the entity's HP.
@export_group("States")
@export var on_hp_0: State ## State to enable when hp reach 0.

var hp_bar: Node ## The health_bar instance.
var immortal := false ## Avoids reducing hp.

@onready var hp := max_hp: ## The entity's current hp.
	set(new_hp):
		hp = new_hp
		hp_changed.emit(hp)

signal hp_changed(value) ## Emitted when hp change.

func _ready():
	_init_health_bar()

func _init_health_bar():
	if health_bar:
		hp_bar = health_bar.instantiate()
		hp_bar.init_hud(self)
		add_child(hp_bar)

func change_hp(value, from = ""):
	var new_hp = hp + value
	if immortal and new_hp < hp:
		return
	set_immortal()
	if new_hp < 0:
		new_hp = 0
	elif new_hp > max_hp:
		new_hp = max_hp
	if new_hp < hp: # Damaged
		print_rich("%s [color=red]damaged[/color] by %s! HP: %s" % [owner.name, from, new_hp])
	elif new_hp > hp: # Recovered
		print_rich("%s [color=green]recovered[/color] by %s! HP: %s" % [owner.name, from, new_hp])
	hp = new_hp
	if hp == 0 and on_hp_0:
		on_hp_0.enable()

func set_immortal():
	immortal = true
	await get_tree().create_timer(recovery_time).timeout
	immortal = false

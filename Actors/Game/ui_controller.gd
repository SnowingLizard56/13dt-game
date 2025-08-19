extends Control

@onready var hp_bar: ProgressBar = $HealthBar/ProgressBar


func update_health(ship: Ship):
	hp_bar.max_value = ship.max_hp
	hp_bar.value = ship.hp

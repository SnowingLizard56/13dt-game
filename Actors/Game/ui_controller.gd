extends Control

@onready var hp_bar: ProgressBar = $HealthBar/Health
@onready var buffer_bar: ProgressBar = $HealthBar/Buffer

var tween: Tween

func update_health(ship: Ship):
	hp_bar.value = ship.hp
	
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	tween.tween_interval(0.5)
	tween.tween_property(buffer_bar, "value", ship.hp, 0.1)


func set_health(ship: Ship):
	hp_bar.max_value = ship.max_hp
	buffer_bar.max_value = ship.max_hp
	hp_bar.value = ship.hp
	buffer_bar.value = ship.hp

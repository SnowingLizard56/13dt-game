class_name TriggerComponent extends ShipComponent

@export var trigger_cooldown: float

var trigger_ready: bool = true


func _trigger(player: Player, _ship: Ship):
	trigger_ready = false
	player.get_tree().create_timer(trigger_cooldown).timeout.connect(
		set.bind(&"trigger_ready", true)
	)


func _get_stat_string() -> String:
	return """Cooldown: {trigger_cooldown} s
	""" + super()

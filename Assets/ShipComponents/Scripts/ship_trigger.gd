class_name TriggerComponent extends ShipComponent

@export var trigger_cooldown: float

var trigger_ready: bool = true
var timer: SceneTreeTimer


func _trigger(player: Player, _ship: Ship):
	trigger_ready = false
	timer = player.get_tree().create_timer(trigger_cooldown)
	await timer.timeout
	trigger_ready = true
	timer = null


func _get_stat_string() -> String:
	return """Cooldown: {trigger_cooldown} s
	""" + super()


func get_time_left_ratio() -> float:
	if timer:
		return timer.time_left / trigger_cooldown
	else:
		return 0

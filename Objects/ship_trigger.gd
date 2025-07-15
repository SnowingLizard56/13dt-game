class_name TriggerComponent extends ShipComponent

@export var trigger_cooldown: float

var trigger_ready: bool = true


func _trigger(player: Player, ship: Ship):
	trigger_ready = false
	await player.get_tree().create_timer(trigger_cooldown).timeout
	trigger_ready = true

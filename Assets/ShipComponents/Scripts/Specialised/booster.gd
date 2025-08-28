class_name Booster extends TriggerComponent

@export var extra_thrust: float
@export var duration: float


func _trigger(player: Player, ship: Ship):
	ship.thrust_modifier += extra_thrust
	await Global.get_tree().create_timer(duration).timeout
	ship.thrust_modifier -= extra_thrust
	super(player, ship)


func _get_stat_string() -> String:
	return """Thrust: {extra_thrust} kN
	Duration: {duration} s
	Cooldown: {trigger_cooldown} s
	""" + super()

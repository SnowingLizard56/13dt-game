class_name Booster extends TriggerComponent

@export var extra_thrust: float
@export var duration: float
@export var kick_time: float


func _trigger(player: Player, ship: Ship):
	if !trigger_ready:
		return
	super(player, ship)
	
	Global.root.player.vx +=  Global.aim.x * kick_time * extra_thrust
	Global.root.player.vy +=  Global.aim.y * kick_time * extra_thrust
	
	ship.thrust_modifier += extra_thrust
	await Global.get_tree().create_timer(duration).timeout
	ship.thrust_modifier -= extra_thrust


func _get_stat_string() -> String:
	return """Thrust: {extra_thrust} kN
	Cooldown: {trigger_cooldown} s
	""" + super()

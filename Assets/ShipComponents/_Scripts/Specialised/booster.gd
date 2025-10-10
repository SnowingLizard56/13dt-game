class_name Booster extends TriggerComponent

const KICK_APPLY_TIME := 0.1
@export var extra_thrust: float
@export var duration: float
@export var kick_time: float
@export var visual_profile: ThrustParticleProfile


func _trigger(player: Player, ship: Ship):
	if !trigger_ready:
		return
	super(player, ship)
	
	var t := player.get_tree().create_tween()
	t.tween_method(apply_kick, 0, KICK_APPLY_TIME, KICK_APPLY_TIME)
	
	ship.thrust_modifier += extra_thrust
	ship.base_thrust_profile = visual_profile
	await timer.timeout
	if ship.base_thrust_profile == visual_profile:
		ship.base_thrust_profile = null
	ship.thrust_modifier -= extra_thrust


func apply_kick(t: float):
	var delta: float = Global.get_process_delta_time()
	Global.root.player.vx += Global.aim.x * kick_time * extra_thrust * delta / KICK_APPLY_TIME
	Global.root.player.vy += Global.aim.y * kick_time * extra_thrust * delta / KICK_APPLY_TIME


func _get_stat_string() -> String:
	return """Thrust: {extra_thrust} kN
	Cooldown: {trigger_cooldown} s
	""" + super()

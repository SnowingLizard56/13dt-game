class_name LaserWeapon extends TriggerComponent

@export var dps: float
@export var sustain: float
@export var rotate_speed: float
@export var width: float


func _trigger(player: Player, ship: Ship):
	if not trigger_ready:
		return
	trigger_ready = false
	# Make laser
	player.make_laser(self)
	await player.get_tree().create_timer(sustain, false).timeout
	super(player, ship)


func _get_stat_string() -> String:
	return """Damage: {dps} Js⁻¹
	Sustain Time: {sustain} s
	Rotation Speed: {rotate_speed} °s⁻¹
	""" + super()

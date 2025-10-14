class_name DebrisEjector extends TriggerComponent

const BONUS_PROJECTILES := 3
const PROJ_RADIUS := 3.
@export var projectile_speed: float
@export var projectile_mass: float
@export var spread: float
@export var count: int



func _trigger(player: Player, ship: Ship):
	if !trigger_ready:
		return
	for i in count + int(player.ship.has_component("Debris Collector")) * BONUS_PROJECTILES:
		var theta := Global.aim.angle() + randf_range(-1, 1) * deg_to_rad(spread)
		var shape := CircleShape2D.new()
		shape.radius = PROJ_RADIUS
		Projectile.new(
			player,
			projectile_speed * cos(theta),
			projectile_speed * sin(theta),
			shape,
			projectile_mass
		)
	super(player, ship)


func _get_stat_string() -> String:
	return """Debris Speed: {projectile_speed} pxs⁻¹
	Debris Mass: {projectile_mass} kg
	Debris Count: {count}
	""" + super()

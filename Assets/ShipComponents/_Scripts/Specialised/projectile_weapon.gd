class_name ProjectileWeapon extends TriggerComponent

@export var projectile_speed: float
@export var projectile_shape: Shape2D
@export var projectile_mass: float
@export var cause_particles_planet: bool = false


func _trigger(player: Player, ship: Ship):
	if !trigger_ready:
		return
	Projectile.new(
		player,
		Global.aim.x * projectile_speed,
		Global.aim.y * projectile_speed,
		projectile_shape,
		projectile_mass,
		cause_particles_planet
		)
	super(player, ship)


func _get_stat_string() -> String:
	return """Bullet Speed: {projectile_speed} pxs⁻¹
	Bullet Mass: {projectile_mass} kg
	""" + super()

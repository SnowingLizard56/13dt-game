class_name DebrisCollector extends ShipComponent

const BONUS_PROJECTILES := 3
const PROJ_RADIUS := 3.
var player: Player
@export var proj_speed := 50
@export var proj_mass := 1.6
@export var count := 6


func _installed(_ship: Ship):
	player = Global.root.player
	player.damage_hook.append(damage_hook)


func _uninstalled(_ship: Ship):
	player = Global.root.player
	player.damage_hook.erase(damage_hook)


func damage_hook(_amt: float, src: int):
	if src == Player.DeathSource.PLANET:
		return
	for i in count + int(player.ship.has_component("Debris Ejector")) * BONUS_PROJECTILES:
		var theta := TAU * randf()
		var shape := CircleShape2D.new()
		shape.radius = PROJ_RADIUS
		Projectile.new(
			player,
			proj_speed * cos(theta),
			proj_speed * sin(theta),
			shape,
			proj_mass
		)


func _get_stat_string() -> String:
	return """Debris Count: {count}
	""" + super()

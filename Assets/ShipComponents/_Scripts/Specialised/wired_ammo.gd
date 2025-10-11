class_name WiredAmmo extends ShipComponent

var player: Player
@export var effect_amnt := 10.0


func impact_hook(projectile: Projectile, target: Node2D):
	if projectile.alive_time > 5.0:
		return
	player = Global.root.player
	if target is Body or target is Enemy:
		var dv: Vector2 = projectile.position.limit_length(effect_amnt * projectile.mass)
		player.vx += dv.x
		player.vy += dv.y


func _get_stat_string() -> String:
	return """Effect Size: {effect_amnt} pxs⁻¹ per projectile kg
	""" + super()

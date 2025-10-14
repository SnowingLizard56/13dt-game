class_name RepulsionUnit extends TriggerComponent

const PLAYER_COLOUR := Player.PLAYER_COLOUR
const WIDTH := 2.0
const FADEOUT_TIME := 0.5
var hb: Area2D
var player_ref: Player
@export var effect_range: float
@export var effect_duration: float
@export var damage: float


func _trigger(player: Player, ship: Ship):
	if not trigger_ready:
		return
	player_ref = player
	super(player, ship)
	
	# Make icon
	hb = Area2D.new()
	hb.collision_layer = 0
	# 12 = 8 + 4 = projectiles + enemies
	hb.collision_mask = 12
	hb.area_entered.connect(_on_area_entered)
	player.add_child(hb)
	var coll := CollisionShape2D.new()
	hb.add_child(coll)
	coll.shape = CircleShape2D.new()
	coll.shape.radius = effect_range
	hb.draw.connect(draw_icon)
	hb.scale = Vector2.ZERO
	var tween := player.get_tree().create_tween()
	tween.tween_property(hb, "scale", Vector2.ONE, effect_duration)
	tween.tween_property(hb, "modulate", Color(1, 1, 1, 0), FADEOUT_TIME)
	tween.tween_callback(hb.queue_free)


func draw_icon():
	hb.draw_circle(Vector2.ZERO, effect_range, PLAYER_COLOUR, false, WIDTH)


func _on_area_entered(area: Area2D):
	if area is Projectile and area.is_enemy:
		# Reverse relative to player. make player owner
		area.source = player_ref
		area.is_enemy = false
		area.vx -= 3 * (area.vx - player_ref.vx)
		area.vy -= 3 * (area.vy - player_ref.vy)
	elif area.get_parent() is Enemy:
		var target: Enemy = area.get_parent()
		target.damage(damage)


func _get_stat_string() -> String:
	return """Effect Duration: {effect_duration} s
	Range: {effect_range} px
	Energy Output: {damage} J																	
	""" + super()

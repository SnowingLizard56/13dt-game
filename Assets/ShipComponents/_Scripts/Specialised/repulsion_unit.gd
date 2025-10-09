class_name RepulsionUnit extends TriggerComponent

const PLAYER_COLOUR := Player.PLAYER_COLOUR
const WIDTH := 2.0
const FADEOUT_TIME := 0.5
var hb: Area2D
var player_ref: Player
@export var range: float
@export var effect_duration: float


func _trigger(player: Player, ship: Ship):
	if !trigger_ready:
		return
	player_ref = player
	super(player, ship)
	
	# Make icon
	hb = Area2D.new()
	hb.collision_layer = 0
	hb.collision_mask = 8
	hb.area_entered.connect(_on_area_entered)
	player.add_child(hb)
	var coll := CollisionShape2D.new()
	hb.add_child(coll)
	coll.shape = CircleShape2D.new()
	coll.shape.radius = range
	hb.draw.connect(draw_icon)
	hb.scale = Vector2.ZERO
	var t := player.get_tree().create_tween()
	t.tween_property(hb, "scale", Vector2.ONE, effect_duration)
	t.tween_property(hb, "modulate", Color(1, 1, 1, 0), FADEOUT_TIME)
	t.tween_callback(hb.queue_free)


func draw_icon():
	hb.draw_circle(Vector2.ZERO, range, PLAYER_COLOUR, false, WIDTH)


func _on_area_entered(area: Area2D):
	if area is Projectile and area.is_enemy:
		# Reverse relative to player. make player owner
		area.source = player_ref
		area.is_enemy = false
		area.vx -= 3 * (area.vx - player_ref.vx)
		area.vy -= 3 * (area.vy - player_ref.vy)


func _get_stat_string() -> String:
	return """Effect Duration: {effect_duration} s
	""" + super()

class_name Shield extends TriggerComponent

const PLAYER_COLOUR := Player.PLAYER_COLOUR
const RADIUS := 20.0
const WIDTH := 2.0
const FADE_TIME := 0.3
const SCALE := 1.5
const ACTI_TIME := 0.2
var icon: Node2D
var player_ref: Player
@export var effect_duration: float


func _trigger(player: Player, ship: Ship):
	if not trigger_ready:
		return
	player_ref = player
	super(player, ship)
	
	# Make icon
	icon = Node2D.new()
	player.add_child(icon)
	icon.draw.connect(draw_icon)
	icon.scale = Vector2.ZERO
	var tween := player.get_tree().create_tween()
	tween.tween_property(icon, "scale", Vector2.ONE, ACTI_TIME)
	player.damage_hook.append(damage_hook)
	await player.get_tree().create_timer(effect_duration, false).timeout
	if icon:
		tween = player.get_tree().create_tween()
		tween.tween_property(icon, "scale", Vector2.ZERO, ACTI_TIME)
		tween.tween_callback(icon.queue_free)
		tween.tween_callback(func(): player_ref.damage_hook.erase(damage_hook))
		icon = null


func damage_hook(_amount: float, _source: int):
	if icon:
		var tween := player_ref.get_tree().create_tween()
		tween.tween_property(icon, "scale", Vector2.ONE * SCALE, FADE_TIME)
		tween.parallel().tween_property(icon, "modulate", Color(1, 1, 1, 0), FADE_TIME)
		tween.tween_callback(icon.queue_free)
		tween.tween_callback(func(): player_ref.damage_hook.erase(damage_hook))
		icon = null
		return true
	else:
		return false


func draw_icon():
	icon.draw_circle(Vector2.ZERO, RADIUS, PLAYER_COLOUR, false, WIDTH)


func _get_stat_string() -> String:
	return """Effect Duration: {effect_duration} s
	""" + super()

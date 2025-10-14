class_name HangarEnemy extends Enemy

const FLYING_ENEMY: PackedScene = preload("res://Actors/Enemies/Flying/flying_enemy.tscn")
const MAX_HP := 228.0
const SPAWN_IV := 200.0
const SPAWN_DISTANCE := 20
const SPAWN_VARIATION := 15.0
const PTS: PackedVector2Array = [
	Vector2.ZERO,
	Vector2(15, 15),
	Vector2(15, -15),
]
const EMIT_COUNT_WEIGHTS: PackedFloat32Array = [0, 15, 17, 15, 6, 2, 1, 0.1]
const NO_SPAWN_COUNT := 32

@onready var burst = $Burst
@onready var fire_rate = $Firerate
@onready var disable_timer = $DisableTimer
var active: bool = false
var burst_count = 0


func _draw() -> void:
	draw_rect(Rect2(-10, -10, 20, 20), current_colour)
	draw_colored_polygon(PTS, current_colour)


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	active = true
	fire_rate.paused = false
	burst.paused = false
	if fire_rate.is_stopped() and burst.is_stopped():
		fire_rate.start()
	disable_timer.stop()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	disable_timer.start()


func _on_disable_timer_timeout() -> void:
	active = false
	fire_rate.paused = true


func _on_burst_timeout() -> void:
	burst_count -= 1
	if burst_count == 0:
		burst.stop()
		fire_rate.start()
	
	if get_tree().get_nodes_in_group("enemies").size() >= NO_SPAWN_COUNT:
		return
	
	var k = FLYING_ENEMY.instantiate()
	
	var position_offset := Vector2.from_angle(rotation) * SPAWN_DISTANCE + \
		Vector2.from_angle(rotation + TAU / 4) * randf_range(-SPAWN_VARIATION, SPAWN_VARIATION)
	
	k.position = global_position
	k.x = x + position_offset.x
	k.y = y + position_offset.y
	k.vx = vx + cos(rotation) * SPAWN_IV
	k.vy = vy + sin(rotation) * SPAWN_IV
	gen.enemy_put_node.add_child(k)


func _on_firerate_timeout() -> void:
	burst.start()
	burst_count = Global.random.rand_weighted(EMIT_COUNT_WEIGHTS)

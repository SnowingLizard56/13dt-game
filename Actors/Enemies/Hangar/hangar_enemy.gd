class_name HangarEnemy extends Enemy

const FLYING_ENEMY: PackedScene = preload("res://Actors/Enemies/Flying/flying_enemy.tscn")
const MAX_HP := 57.0
const SPAWN_IV := 200.0
const SPAWN_DISTANCE := 20
const SPAWN_VARIATION := 15.0
const PTS: PackedVector2Array = [
	Vector2.ZERO,
	Vector2(15, 15),
	Vector2(15, -15)
]
const EMIT_COUNT_WEIGHTS: PackedFloat32Array = [
	0, 10, 20, 10, 8, 4, 2, 1
]

var active: bool = false
var burst_count = 0


func _draw() -> void:
	draw_rect(Rect2(-10, -10, 20, 20), current_colour)
	draw_colored_polygon(PTS, current_colour)


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	active = true
	$Firerate.paused = false
	$Burst.paused = false
	if $Firerate.is_stopped() and $Burst.is_stopped():
		$Firerate.start()
	$DisableTimer.stop()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	$DisableTimer.start()


func _on_disable_timer_timeout() -> void:
	active = false
	$Firerate.paused = true


func _on_burst_timeout() -> void:
	burst_count -= 1
	var k = FLYING_ENEMY.instantiate()
	
	var position_offset := Vector2.from_angle(rotation) * SPAWN_DISTANCE + \
		Vector2.from_angle(rotation + TAU / 4) * randf_range(-SPAWN_VARIATION, SPAWN_VARIATION)
	
	k.position = global_position
	k.x = x + position_offset.x
	k.y = y + position_offset.y
	k.vx = vx + cos(rotation) * SPAWN_IV
	k.vy = vy + sin(rotation) * SPAWN_IV
	gen.enemy_put_node.add_child(k)
	if burst_count == 0:
		$Burst.stop()
		$Firerate.start()


func _on_firerate_timeout() -> void:
	$Burst.start()
	burst_count = Global.random.rand_weighted(EMIT_COUNT_WEIGHTS)

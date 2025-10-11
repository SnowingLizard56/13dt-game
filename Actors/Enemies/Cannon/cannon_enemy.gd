class_name CannonEnemy extends Enemy

const MAX_HP: float = 125
const MAX_ANGLE: float = 0.2 * TAU
const PROJECTILE_IV: float = 365 # Like a year. lol
const MAX_ROTATION_SPEED: float = 0.2 * TAU
const PROJECTILE_OFFSET_DIST: float = 15.0
const PROJECTILE_MASS: float = 7.3

@onready var barrel: Node2D = $Barrel
@onready var barrel_vis: Node2D = $Barrel/Barrel

var target_barrel_rotation: float
var active: bool = false


func _process(delta: float) -> void:
	target_barrel_rotation = global_position.angle_to_point(root.player.position)
	
	var angle_diff: float = angle_difference(barrel.global_rotation, target_barrel_rotation)
	barrel.global_rotation += sign(angle_diff) * min(abs(angle_diff), MAX_ROTATION_SPEED * delta)
	
	barrel.rotation = clampf(barrel.rotation, -MAX_ANGLE, MAX_ANGLE)


func _draw() -> void:
	draw_circle(Vector2.ZERO, 10, current_colour)


func _on_barrel_draw() -> void:
	barrel_vis.draw_rect(
		Rect2(Vector2(0, -4), Vector2(20, 8)),
		current_colour
	)


func fire_bullet() -> void:
	var t: Tween = get_tree().create_tween()
	t.set_ease(Tween.EASE_OUT)
	t.tween_property(barrel_vis, "position", Vector2(-5, 0), 0.1)
	t.tween_property(barrel_vis, "position", Vector2(0, 0), 0.5)
	
	var shape = CircleShape2D.new()
	var dir := Vector2.from_angle(barrel.global_rotation)
	shape.radius = 5
	var p := Projectile.new(
		self,
		PROJECTILE_IV * dir.x,
		PROJECTILE_IV * dir.y,
		shape,
		PROJECTILE_MASS,
		true
	)
	p.x += dir.x * PROJECTILE_OFFSET_DIST
	p.y += dir.y * PROJECTILE_OFFSET_DIST
	p._physics_process(get_physics_process_delta_time())


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	active = true
	$Firerate.paused = false
	if $Firerate.is_stopped():
		$Firerate.start()
	$DisableTimer.stop()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	$DisableTimer.start()


func _on_disable_timer_timeout() -> void:
	active = false
	$Firerate.paused = true

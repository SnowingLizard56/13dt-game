class_name CannonEnemy extends Enemy

const MAX_HP: float = 125

func _draw() -> void:
	draw_circle(Vector2.ZERO, 10, ENEMY_COLOUR)


func _on_barrel_draw() -> void:
	$Barrel/Barrel.draw_rect(
		Rect2(Vector2(0, 0), Vector2(20, 8)),
		ENEMY_COLOUR
	)


func fire_bullet() -> void:
	var t: Tween = get_tree().create_tween()
	t.set_ease(Tween.EASE_OUT)
	t.tween_property($Barrel/Barrel, "position", Vector2(-5, 0), 0.1)
	t.tween_property($Barrel/Barrel, "position", Vector2(0, 0), 0.5)
	
	var shape = CircleShape2D.new()
	shape.radius = 5
	# TODO
	Projectile.new(
		self,
		0,
		0,
		shape
	)

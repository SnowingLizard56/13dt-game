class_name Player extends Area2D

const SPRITE_RADIUS: int = 5

signal player_died

# floats are stored with double precision. Vector2s are single precision.
var x: float = 750.0
var y: float = 750.0
var vx: float = 0.0
var vy: float = 0.0

var level: Level

#@onready var ship: Ship = Global.player_ship
@export var ship: Ship


func _ready() -> void:
	ship.set_components()


func _process(delta: float) -> void:
	# Visual
	rotate(-delta)
	
	# Triggers
	if Input.is_action_just_pressed("trigger_1"):
		ship.trigger(0, self)
	if Input.is_action_just_pressed("trigger_2"):
		ship.trigger(1, self)
	if Input.is_action_just_pressed("trigger_3"):
		ship.trigger(2, self)
	if Input.is_action_just_pressed("trigger_4"):
		ship.trigger(3, self)
	
	# Take input
	var acceleration_input = Vector2(
		Input.get_axis("player_left", "player_right"),
		Input.get_axis("player_up", "player_down")
	).normalized()
	
	# Velocity then position
	vx += ship.acceleration * acceleration_input.x * delta
	vy += ship.acceleration * acceleration_input.y * delta
	
	if !level:
		level = get_parent().level
	
	var grav: Dictionary = level.barnes_hut_probe(delta * Global.time_scale ** 2, x, y, 1.0, 0.0)
	vx += grav.ax
	vy += grav.ay
	
	x += vx * delta
	y += vy * delta


func _draw() -> void:
	var sq_pts: PackedVector2Array = [
		Vector2(SPRITE_RADIUS, SPRITE_RADIUS),
		Vector2(-SPRITE_RADIUS, SPRITE_RADIUS),
		Vector2(-SPRITE_RADIUS, -SPRITE_RADIUS),
		Vector2(SPRITE_RADIUS, -SPRITE_RADIUS)
	]
	draw_colored_polygon(sq_pts, Color("20a5a6"))


func _on_collision_area_entered(area: Area2D) -> void:
	if area.collision_layer == 2:
		player_died.emit()
		get_tree().paused = true

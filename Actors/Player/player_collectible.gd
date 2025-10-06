class_name CollectParticle extends Node2D

const BG_COLOUR: Color = Color(0.059, 0.106, 0.149, 1.0)
const SOLID_COLOUR: Color = Color(0.961, 0.91, 0.82, 1.0)
const PLAYER_COLOUR: Color = Color(0.125, 0.647, 0.651, 1.0)
const ENEMY_COLOUR: Color = Color(0.867, 0.337, 0.224, 1.0)
const UNKNOWN_COLOUR: Color = Color(1.0, 0.937255, 0.631373, 1.0)

const ALLOWED_ANGLE_OFFSET := TAU * 0.1
const TIME_MIN := 1.0
const TIME_MAX := 2.0
const DISTANCE := 50.0

const SCALE_CURVE : Curve = preload("res://Actors/Player/scale_curve.tres")

var distance: float
var angle: float
var time: float = 0.0
var colour: Color

enum Types {XP, HP, E127}
const TYPE_COLOURS: PackedColorArray = [PLAYER_COLOUR, ENEMY_COLOUR, UNKNOWN_COLOUR]
var type: Types
var distance_constant: float
var value: float

signal reach_player


func _init(t: Types, pos: Vector2, v: float = 1.0) -> void:
	type = t
	pos += Vector2(randf_range(-1, 1), randf_range(-1, 1)) * 5
	angle = pos.angle()
	distance = pos.length()
	Global.root.add_child(self)
	value = v
	_process(0)
	colour = TYPE_COLOURS[t]
	# Yayyyy magic function
	distance_constant = sqrt((DISTANCE / distance + 1) ** 2 - 1) + 2 * DISTANCE / distance + 0.5
	z_index = 3

	
func _ready() -> void:
	rotation = randf() * TAU
	var t: Tween = get_tree().create_tween()
	var lifetime = randf_range(TIME_MIN, TIME_MAX)
	t.tween_property(self, "angle",
		angle + randf_range(-ALLOWED_ANGLE_OFFSET, ALLOWED_ANGLE_OFFSET),
		lifetime
		)
	t.parallel().tween_property(
		self, "time",
		1.0,
		lifetime
	)
	t.tween_callback(finish)


func _process(_delta: float) -> void:
	position = Vector2.from_angle(angle) * get_distance(time) * distance
	scale = Vector2.ONE * get_scale_factor(time)


func _draw() -> void:
	draw_rect(Rect2(-2.5, -2.5, 5, 5), colour)


func get_distance(t: float):
	return -distance_constant * t ** 2 + distance_constant * t - t + 1


func get_scale_factor(t: float):
	return SCALE_CURVE.sample_baked(t)


func finish():
	reach_player.emit()
	if type == Types.XP:
		Global.root.ui.add_xp(value)
	elif type == Types.E127:
		Global.player_currency += int(value)
	elif type == Types.HP:
		Global.root.player.ship.hp = min(Global.root.player.ship.max_hp, Global.root.player.ship.hp + value)
	Global.root.ui.update_all()
	queue_free()

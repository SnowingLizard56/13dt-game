class_name MapIcon extends Area2D

const XARAGILN: PackedScene = preload("res://Assets/Profiles/xaragiln_profile.tscn")
const NAMURANT: PackedScene = preload("res://Assets/Profiles/namurant_profile.tscn")
const SHOP: PackedScene = preload("res://Assets/Profiles/s_profile.tscn")
const UNCLAIMED: PackedScene = preload("res://Assets/Profiles/unclaimed_profile.tscn")
const EVENT: PackedScene = preload("res://Assets/Profiles/random_profile.tscn")

const SCALE_HOVERED: float = 0.42
const SCALE_NORMAL: float = 0.38

var in_map: bool = false
var connections: Array[MapIcon]
var nebula: Nebula

var map_position: Vector2
var list_position: int


func _draw() -> void:
	# Background
	draw_circle(Vector2.ZERO, 100, Color("0f1b26"))
	if !nebula:
		return
	for i in get_children():
		if not i is CollisionShape2D:
			i.queue_free()
	# Match for nebula type
	var pf: Node2D
	match nebula.type:
		nebula.EVENT:
			pf = EVENT.instantiate()
			pf.colour = Color("ffefa1")
		nebula.UNCLAIMED:
			# Circle
			pf = UNCLAIMED.instantiate()
			pf.colour = Color("f5e8d1")
		nebula.XARAGILN:
			# Namurant profile
			pf = XARAGILN.instantiate()
			pf.colour = Color("dd5639")
		nebula.NAMURANT:
			pf = NAMURANT.instantiate()
			pf.colour = Color("20a5a6")
		nebula.SHOP:
			pf = SHOP.instantiate()
			pf.colour = Color("f5e8d1")
			draw_circle(Vector2.ZERO, 88, Color("f5e8d1"), false)
	#
	add_child(pf)


func _ready() -> void:
	var col: CollisionShape2D = CollisionShape2D.new()
	col.shape = CircleShape2D.new()
	col.shape.radius = 100
	add_child(col)


func _mouse_enter() -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2.ONE * SCALE_HOVERED, 0.1)


func _mouse_exit() -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2.ONE * SCALE_NORMAL, 0.1)

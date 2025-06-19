class_name MapIcon extends Node2D	

@onready var xaragiln: PackedScene = preload("res://Assets/xaragiln_profile.tscn")
@onready var namurant: PackedScene = preload("res://Assets/namurant_profile.tscn")
@onready var shop: PackedScene = preload("res://Assets/s_profile.tscn")

var nebula: Nebula

func _ready() -> void:
	nebula = Nebula.new()
	nebula.play_modifier = nebula.play_modifiers.RECHART_COURSE
	nebula.type = nebula.SHOP


func _draw() -> void:
	scale = Vector2.ONE * 0.2
	if !nebula:
		return
	for i in get_children():
		i.queue_free()
	# Match for nebula type
	var pf:Node2D
	match nebula.type:
		nebula.UNCLAIMED:
			# Circle
			pf = Node2D.new()
			pf.draw.connect(pf.draw_circle.bind(Vector2.ZERO, 88, Color("f5e8d1"), false))
		nebula.XARAGILN:
			# Namurant profile
			pf = xaragiln.instantiate()
			if Global.is_xaragiln_friendly:
				pf.colour = Color("20a5a6")
			else:
				pf.colour = Color("dd5639")
		nebula.NAMURANT:
			pf = namurant.instantiate()
			if Global.is_namurant_friendly:
				pf.colour = Color("20a5a6")
			else:
				pf.colour = Color("dd5639")
		nebula.SHOP:
			pf = shop.instantiate()
			pf.colour = Color("f5e8d1")
			draw_circle(Vector2.ZERO, 88, Color("f5e8d1"), false)
	#
	add_child(pf)
		
	# Map-Visible Modifiers
	var mdfr
	match nebula.play_modifier:
		nebula.play_modifiers.UNDER_ATTACK:
			mdfr = Node2D.new()
			if nebula.is_friendly or (!Global.is_xaragiln_friendly and !Global.is_namurant_friendly):
				mdfr.draw.connect(mdfr.draw_circle.bind(Vector2.ZERO, 100, Color("dd5639"), false))
			else:
				mdfr.draw.connect(mdfr.draw_circle.bind(Vector2.ZERO, 100, Color("20a5a6"), false))
		nebula.play_modifiers.RECHART_COURSE:
			mdfr = Node2D.new()
			# Weird freaky little pattern
			mdfr.draw.connect(draw_arcs.bind(mdfr))
	if mdfr:
		add_child(mdfr)


func draw_arcs(node: Node2D):
	var pts: PackedFloat32Array = []
	for i in 10:
		pts.append(randf_range(0, TAU))
	pts.sort()
	var last = 0
	for i in pts:
		node.draw_arc(Vector2.ZERO, 100, last, i*0.9, 10, Color("f5e8d1"))
		last = i

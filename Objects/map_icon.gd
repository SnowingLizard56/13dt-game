class_name MapIcon extends Button

const XARAGILN: PackedScene = preload("res://Assets/Profiles/xaragiln_profile.tscn")
const NAMURANT: PackedScene = preload("res://Assets/Profiles/namurant_profile.tscn")
const SHOP: PackedScene = preload("res://Assets/Profiles/s_profile.tscn")
const UNCLAIMED: PackedScene = preload("res://Assets/Profiles/unclaimed_profile.tscn")
const EVENT: PackedScene = preload("res://Assets/Profiles/random_profile.tscn")

const SCALE_HOVERED: float = 0.46
const SCALE_NORMAL: float = 0.38
const HITBOX_SIZE: float = 200.0

const HUD_COLOUR: Color = Color(0.0741176, 0.132941, 0.188235, 1)
const PLAYER_COLOUR: Color = Color(0.12549, 0.647059, 0.65098, 1)

var in_map: bool = false
var connections: Array[MapIcon]
var nebula: Nebula

var map_position: Vector2
var list_position: int
var drawn = false
var profile: Node2D
@onready var scale_val: float = SCALE_NORMAL
@onready var map: MapController = get_parent()


func _draw() -> void:
	# Background
	draw_circle(size / 2, 100 * scale_val / SCALE_NORMAL, HUD_COLOUR)
	if has_focus():
		draw_circle(size / 2, 100 * scale_val / SCALE_NORMAL, PLAYER_COLOUR, false, 3.0)
	if !nebula:
		return
	if drawn:
		return
	drawn = true
	# Match for nebula type
	match nebula.type:
		nebula.EVENT:
			profile = EVENT.instantiate()
			profile.colour = Color("ffefa1")
		nebula.UNCLAIMED:
			# Circle
			profile = UNCLAIMED.instantiate()
			profile.colour = Color("f5e8d1")
		nebula.XARAGILN:
			# Namurant profile
			profile = XARAGILN.instantiate()
			profile.colour = Color("dd5639")
		nebula.NAMURANT:
			profile = NAMURANT.instantiate()
			profile.colour = Color("20a5a6")
		nebula.SHOP:
			profile = SHOP.instantiate()
			profile.colour = Color("f5e8d1")
	#
	add_child(profile)
	profile.position = size / 2


func _ready() -> void:
	theme = get_parent().theme
	size = Vector2.ONE * HITBOX_SIZE
	position -= scale * size / 2
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)
	mouse_entered.connect(grab_focus)
	theme_type_variation = "SemiButton"
	focus_entered.connect(map.icon_focused.bind(self))


func _on_focus_entered():
	var t := get_tree().create_tween()
	t.tween_method(change_scale, SCALE_NORMAL, SCALE_HOVERED, 0.1)
	t.parallel().tween_property(profile, "scale", Vector2.ONE * SCALE_HOVERED / SCALE_NORMAL, 0.1)
	queue_redraw()


func _on_focus_exited():
	var t := get_tree().create_tween()
	t.tween_method(change_scale, SCALE_HOVERED, SCALE_NORMAL, 0.1)
	t.parallel().tween_property(profile, "scale", Vector2.ONE, 0.1)
	queue_redraw()


func change_scale(_scale):
	scale_val = _scale
	queue_redraw()

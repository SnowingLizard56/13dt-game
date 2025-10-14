class_name MapIcon extends Button

const XARAGILN: PackedScene = preload("res://Assets/IdeaIcons/xaragiln_profile.tscn")
const NAMURANT: PackedScene = preload("res://Assets/IdeaIcons/namurant_profile.tscn")
const SHOP: PackedScene = preload("res://Assets/IdeaIcons/s_profile.tscn")
const UNCLAIMED: PackedScene = preload("res://Assets/IdeaIcons/unclaimed_profile.tscn")
const EVENT: PackedScene = preload("res://Assets/IdeaIcons/random_profile.tscn")

const SCALE_HOVERED: float = 0.46
const SCALE_PRESSED: float = 0.43
const SCALE_NORMAL: float = 0.38
const HITBOX_SIZE: float = 200.0

const HUD_COLOUR: Color = Color(0.0741176, 0.132941, 0.188235, 1)
const PLAYER_COLOUR: Color = Color(0.12549, 0.647059, 0.65098, 1)
const EVENT_COLOUR := Color(1, 0.937255, 0.631373, 1)
const PLAIN_COLOUR := Color(0.960784, 0.909804, 0.819608, 1)
const ENEMY_COLOUR := Color(0.866667, 0.337255, 0.223529, 1)

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
	if map.focused_icon == self:
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
			profile.colour = EVENT_COLOUR
		nebula.UNCLAIMED:
			# Circle
			profile = UNCLAIMED.instantiate()
			profile.colour = PLAIN_COLOUR
		nebula.XARAGILN:
			# Namurant profile
			profile = XARAGILN.instantiate()
			profile.colour = ENEMY_COLOUR
		nebula.NAMURANT:
			profile = NAMURANT.instantiate()
			profile.colour = PLAYER_COLOUR
		nebula.SHOP:
			profile = SHOP.instantiate()
			profile.colour = PLAIN_COLOUR
	#
	add_child(profile)
	profile.position = size / 2


func _ready() -> void:
	theme = get_parent().theme
	size = Vector2.ONE * HITBOX_SIZE
	position -= scale * size / 2
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)
	mouse_entered.connect(hovered)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	theme_type_variation = "SemiButton"
	focus_entered.connect(map.icon_focused.bind(self))
	pressed.connect(map.icon_pressed.bind(self))


func _on_focus_entered():
	var t := get_tree().create_tween()
	t.tween_method(change_scale, scale_val, SCALE_HOVERED, 0.2)
	t.parallel().tween_property(profile, "scale", Vector2.ONE * SCALE_HOVERED / SCALE_NORMAL, 0.2)


func _on_focus_exited():
	var t := get_tree().create_tween()
	t.tween_method(change_scale, scale_val, SCALE_NORMAL, 0.2)
	t.parallel().tween_property(profile, "scale", Vector2.ONE, 0.2)


func _on_button_down():
	if not has_focus():
		return
	var t := get_tree().create_tween()
	t.tween_method(change_scale, scale_val, SCALE_PRESSED, 0.05)
	t.parallel().tween_property(profile, "scale", Vector2.ONE * SCALE_PRESSED / SCALE_NORMAL, 0.05)


func _on_button_up():
	if not has_focus():
		return
	var t := get_tree().create_tween()
	t.tween_method(change_scale, scale_val, SCALE_HOVERED, 0.05)
	t.parallel().tween_property(profile, "scale", Vector2.ONE * SCALE_HOVERED / SCALE_NORMAL, 0.05)


func change_scale(_scale):
	scale_val = _scale
	queue_redraw()


func hovered():
	if focus_mode == Control.FOCUS_ALL:
		grab_focus()
	

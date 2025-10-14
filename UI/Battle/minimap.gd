extends Panel

const SCREEN_SIZE := Vector2(1152, 648)
const PLAYER_COLOUR := Color("20a5a6")
@export var gridline_count := Vector2i(7, 7)
@export var zoom: float = 1.0
@export var levelcontroller: Node2D
@export var follow_player: bool = false
@export var draw_player: bool = true
@export var target_parent: Node
@onready var coll : CollisionShape2D = $Area2D/CollisionShape2D
@onready var hb: Area2D = $Area2D

var level: Level


func _ready() -> void:
	get_child(0).position = size / 2
	coll.shape.size = size
	await Global.frame_next
	hb.reparent(target_parent, false)
	hb.position = size / 2 - SCREEN_SIZE / 2 + position


func _process(_delta: float) -> void:
	if not level:
		level = levelcontroller.level
		return
	if hb.get_overlapping_areas():
		modulate.a = 0.5
	else:
		modulate.a = 1.0
	get_child(0).queue_redraw()


func _on_drawer_draw() -> void:
	if not level:
		return
	var d: Node2D = get_child(0)
	var x: float = 0
	var y: float = 0
	if follow_player:
		x = levelcontroller.player.x
		y = levelcontroller.player.y
	# Draw Bodies
	for b in level.get_bodies():
		d.draw_circle(Vector2(b.x - x, b.y - y) * zoom, max(b.r * zoom, 2), Color.WHITE)
	# Draw Player
	if draw_player:
		d.draw_circle(Vector2(
			levelcontroller.player.x - x, levelcontroller.player.y - y) * zoom, 1, PLAYER_COLOUR)

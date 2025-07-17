extends ColorRect

@export var zoom: float = 1.0
@export var levelcontroller: Node2D
@export var follow_player: bool = false

var level: Level


func _ready() -> void:
	get_child(0).position = size / 2


func _process(_delta: float) -> void:
	if !level:
		level = levelcontroller.level
		return
	get_child(0).queue_redraw()


func _on_drawer_draw() -> void:
	var d: Node2D = get_child(0)
	if !level:
		return
	var x: float = 0
	var y: float = 0
	if follow_player:
		x = levelcontroller.player.x
		y = levelcontroller.player.y
	for b in level.get_bodies():
		d.draw_circle(Vector2(b.x - x, b.y - y) * zoom, max(b.r * zoom, 2), Color.WHITE)

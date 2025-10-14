extends Control

const DISTANCE := 1000
@export var titles: PackedStringArray
@export var title: Label
@export var button: CustomButton
@export var dim: ColorRect
@export var cover: ColorRect


func start():
	const SLOW_TIME := 0.2
	const DIM_TIME := 0.2
	const TITLE_MOVE_TIME := 0.5
	const INTERVAL_TIME := 0.8
	const BUTTON_MOVE_TIME := 0.4
	show()
	title.position = Vector2.from_angle(randf() * TAU) * DISTANCE
	button.position = Vector2(0, 250)
	title.text = titles[randi() % len(titles)]
	dim.modulate.a = 0
	var tween := get_tree().create_tween()
	tween.set_ignore_time_scale()
	tween.tween_property(Engine, "time_scale", 0, SLOW_TIME)
	tween.tween_property(dim, "modulate", Color.WHITE, DIM_TIME)
	tween.tween_property(title, "position", Vector2.ZERO, TITLE_MOVE_TIME).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_interval(INTERVAL_TIME)
	tween.tween_property(button, "position", Vector2.ZERO, BUTTON_MOVE_TIME)
	tween.tween_callback(button.grab_focus)


func _on_continue_pressed() -> void:
	var FADEOUT_TIME := 0.7
	cover.show()
	cover.modulate.a = 0
	var tween := get_tree().create_tween()
	tween.set_ignore_time_scale()
	tween.tween_property(cover, "modulate", Color.WHITE, FADEOUT_TIME)
	tween.tween_callback(func(): Global.switch_to_map(Global.root.player.ship))

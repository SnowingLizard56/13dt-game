extends Control

@export var dim_bg: ColorRect
@export var title_label: Label
@export var score_label: Label
@export var killed_by_label: Label
@export var tip_label: Label
@export var quit_button: CustomButton
@export var again_button: CustomButton
@export var panel: Panel

@export var titles: PackedStringArray
@export_multiline var tips: PackedStringArray
@export var killed_by: PackedStringArray


func _on_player_player_died() -> void:
	const PANEL_MOVE_AMOUNT := Vector2(0, 800.0)
	
	killed_by_label.text = killed_by[%Player.death_source]
	title_label.text = titles[randi() % len(titles)]
	tip_label.text = tips[randi() % len(tips)]
	
	show()
	
	title_label.modulate.a = 0.0
	score_label.modulate.a = 0.0
	killed_by_label.modulate.a = 0.0
	tip_label.modulate.a = 0.0
	quit_button.modulate.a = 0.0
	again_button.modulate.a = 0.0
	dim_bg.modulate.a = 0.0
	panel.position += PANEL_MOVE_AMOUNT
	
	var t := get_tree().create_tween()
	t.tween_interval(3.0)
	t.tween_property(dim_bg, "modulate", Color.WHITE, 0.5)
	t.tween_property(panel, "position", panel.position - PANEL_MOVE_AMOUNT, 0.5)\
		.set_trans(Tween.TRANS_QUAD)
	t.tween_property(title_label, "modulate", Color.WHITE, 0.3)
	t.tween_property(score_label, "modulate", Color.WHITE, 0.3)
	t.tween_property(killed_by_label, "modulate", Color.WHITE, 0.3)
	t.tween_property(tip_label, "modulate", Color.WHITE, 0.3)
	t.tween_callback(quit_button.grab_focus)
	t.tween_property(quit_button, "modulate", Color.WHITE, 0.3)
	t.parallel().tween_property(again_button, "modulate", Color.WHITE, 0.3)


func _on_quit_pressed() -> void:
	Global.switch_scene(Global.MAIN_MENU_SCENE)


func _on_again_pressed() -> void:
	Global.switch_scene(Global.game_scene)

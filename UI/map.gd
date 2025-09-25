class_name MapOwner extends Node2D

const BG_SIZE := Vector2(1152, 648)
const RIGHT_OFFSET := 325
const SIZE_SCALING := 0.19
const TYPE_NAMES: PackedStringArray = ["Event", "1", "Shop", "Battle", "Rest", "5"]

@export var cam: Camera2D
@export var inner: MapController
@export var confirmation: Control
@export var conf_title: Label
@export var confirm_button: CustomButton
@export var cancel_button: CustomButton
@export var fadeout: ColorRect
@onready var conf_start: Vector2 = confirmation.position
@onready var conf_move: Vector2 = confirmation.size * Vector2.RIGHT

var cover:
	get():
		return fadeout

signal icon_selected(neb: Nebula)


func _on__map_inner_any_icon_pressed() -> void:
	var end_position = (inner.player_icon.global_position + inner.player_icon.size * SIZE_SCALING\
		+ inner.focused_icon.global_position + inner.focused_icon.size * SIZE_SCALING) / 2
	inner.release_focus()
	
	var rightmost = max(inner.player_icon.global_position.x,inner.focused_icon.global_position.x)\
		+ SIZE_SCALING * inner.player_icon.size.x
	end_position.x = rightmost - BG_SIZE.x / 2 + RIGHT_OFFSET
	
	confirmation.show()
	confirmation.position = conf_start - conf_move
	conf_title.text = TYPE_NAMES[inner.player_icon.nebula.type] + " -> "\
		+ TYPE_NAMES[inner.focused_icon.nebula.type]
	confirm_button.disabled = false
	cancel_button.disabled = false
	confirm_button.grab_focus()
	
	var t := get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	t.tween_property(cam, "position", end_position, 0.75)
	t.parallel().tween_property(confirmation, "position", conf_start, 0.75)


func reset_cam(time: float):
	var t := get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	t.tween_property(cam, "position", BG_SIZE / 2, time)
	if confirmation.visible:
		t.parallel().tween_property(confirmation, "position", conf_start - conf_move, time)
		t.tween_callback(confirmation.hide)
		t.tween_callback(inner.grab_focus)


func reset_cam_to_mid(time: float):
	var t := get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	var avg_pos = inner.player_icon.global_position + inner.player_icon.size * SIZE_SCALING
	t.tween_property(cam, "position", avg_pos, time)
	if confirmation.visible:
		t.parallel().tween_property(confirmation, "position", conf_start - conf_move, time)
		t.tween_callback(confirmation.hide)
		t.tween_callback(inner.grab_focus)


func _on_cancel_pressed() -> void:
	reset_cam(0.75)


func _on_confirm_pressed() -> void:
	reset_cam_to_mid(0.6)
	await get_tree().create_timer(0.6).timeout
	inner.take_step()
	await get_tree().create_timer(MapPlayer.MOVE_TIME).timeout
	icon_selected.emit(inner.player_icon.nebula)


func _on_icon_selected(neb: Nebula) -> void:
	const DELAY_TIME := 1.0
	const FADE_TIME := 0.7
	var t: Tween = get_tree().create_tween()
	
	if neb.type == Nebula.SHOP or neb.type == Nebula.XARAGILN:
		# Fade out
		fadeout.show()
		fadeout.modulate.a = 0
		t.tween_interval(DELAY_TIME)
		t.tween_property(fadeout, "modulate", Color.WHITE, FADE_TIME)
		await get_tree().create_timer(FADE_TIME + DELAY_TIME).timeout
		# Switch scene
		cam.enabled = false
		hide()
		if neb.type == Nebula.SHOP:
			Global.switch_scene(Global.SHOP_SCENE)
		else:
			Global.switch_scene(load(Global.GAME_FILE_PATH))
		reset_cam(0)
	else:
		# TODO
		# Event
		# await event.finished
		reset_cam(1.2)


func reinit():
	cam.enabled = true
	show()
	inner.grab_focus(true)

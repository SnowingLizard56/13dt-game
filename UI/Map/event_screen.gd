extends Control

const BG_SIZE := Vector2(1152, 648)
const DIM_TIME := 0.75
const MOVE_TIME := 0.25

@export var dimmer: ColorRect
@export var option: PackedScene
@export var title: Label
@export var exposition: Label
@export var options_holder: VBoxContainer
@export var map_ui: MapUI

signal event_finished


func handle_event(event: MapEvent, dim: bool = true):
	for i in options_holder.get_children():
		i.queue_free()
	
	show()
	position.y = BG_SIZE.y
	
	var tween := get_tree().create_tween()
	if dim:
		dimmer.modulate.a = 0
		dimmer.show()
		tween.tween_property(dimmer, "modulate", Color.WHITE, DIM_TIME)
	tween.tween_property(self, "position", Vector2.ZERO, MOVE_TIME)
	
	title.text = event.title
	exposition.text = event.exposition
	
	for opt in event.options:
		var k: CustomButton = option.instantiate()
		options_holder.add_child(k)
		k.text = opt.title
		k.pressed.connect(option_chosen.bind(opt))
	
	tween.tween_callback(options_holder.get_child(-1).grab_focus)


func option_chosen(opt: EventEffect):
	var tween := get_tree().create_tween()
	for button in options_holder.get_children():
		for connection in button.pressed.get_connections():
			connection.signal.disconnect(connection.callable)
	tween.tween_property(self, "position", Vector2(0, BG_SIZE.y), MOVE_TIME)
	var next_event := opt.apply(map_ui, Global.player_ship)
	
	if next_event:
		tween.tween_callback(handle_event.bind(next_event, false))
	elif opt.has_components:
		tween.tween_callback(func(): map_ui.offer_components(opt.get_components()))
		await map_ui.component_control_finished
		event_finished.emit()
	else:
		tween.tween_property(dimmer, "modulate", Color(1, 1, 1, 0), DIM_TIME)
		tween.tween_callback(hide)
		tween.tween_callback(dimmer.hide)
		tween.tween_callback(event_finished.emit)

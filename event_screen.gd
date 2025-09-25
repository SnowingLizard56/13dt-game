extends Control

@export var dimmer: ColorRect
@export var option: PackedScene
@export var title: Label
@export var exposition: Label
@export var options_holder: VBoxContainer
@export var map_ui: MapUI


func handle_event(event: MapEvent):
	title.text = event.title
	exposition.text = event.exposition
	
	for opt in event.options:
		var k: CustomButton = option.instantiate()
		options_holder.add_child(k)
		k.text = opt.title
		k.pressed.connect(option_chosen.bind(opt))


func option_chosen(opt: EventEffect):
	opt.apply(map_ui, Global.player_ship)

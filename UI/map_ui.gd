class_name MapUI extends Control

const BG_SIZE := Vector2(1152, 648)

@export var currency_display: CurrencyDisplay
@export var currency_delta: Control	
@export var hp_bar: ProgressBar
@export var component_control: ComponentControl
@export var dimmer: ColorRect

var transfer_amount: int = 0
var transfer: bool = true

signal component_control_finished


func _ready() -> void:
	currency_display.apply_amount(Global.player_currency)
	update_hp()


func change_currency(amount: int):
	if -amount > Global.player_currency:
		amount = -Global.player_currency
	Global.player_currency += amount
	transfer_amount += amount
	currency_delta.apply_amount(amount)
	transfer = false
	await get_tree().create_timer(log(abs(transfer_amount)) / log(100)).timeout
	transfer = true


func _process(_delta: float) -> void:
	if transfer_amount != 0 and transfer:
		var change = sign(transfer_amount)
		transfer_amount -= change
		currency_display.apply_amount(currency_display.value + change)
		currency_delta.apply_amount(transfer_amount)


func offer_components(components: Array[ShipComponent]):
	component_control.start(components, Global.player_ship)
	component_control.show()
	
	component_control.position.y += BG_SIZE.y
	
	var t1 := get_tree().create_tween()
	t1.tween_property(component_control, "position", Vector2.ZERO, 0.75)
	await component_control.continue_pressed
	var t2 := get_tree().create_tween()
	t2.tween_property(component_control, "position", Vector2(0, BG_SIZE.y), 0.75)
	t2.tween_callback(component_control.finish)
	t2.tween_callback(component_control.hide)
	t2.tween_property(dimmer, "modulate", Color(1, 1, 1, 0), 0.5)
	t2.tween_callback(dimmer.hide)
	t2.tween_callback(component_control_finished.emit)


func update_hp():
	hp_bar.max_value = Global.player_ship.max_hp
	hp_bar.value = Global.player_ship.hp

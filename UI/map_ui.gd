class_name MapUI extends Control

@export var currency_display: CurrencyDisplay
@export var currency_delta: Control	
@export var hp_bar: ProgressBar
@export var component_control: ComponentControl

var transfer_amount: int = 0
var transfer: bool = true


func _ready() -> void:
	currency_display.apply_amount(Global.player_currency)
	hp_bar.max_value = Global.player_ship.max_hp
	hp_bar.value = Global.player_ship.hp


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

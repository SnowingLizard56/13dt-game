class_name ShopController extends Control

const BG_COLOUR: Color = Color(0.059, 0.106, 0.149, 1.0)
const PLAYER_COLOUR: Color = Color(0.125, 0.647, 0.651, 1.0)
const SOLID_COLOUR: Color = Color(0.961, 0.91, 0.82, 1.0)
const ENEMY_COLOUR: Color = Color(0.867, 0.337, 0.224, 1.0)

@onready var bg: Control = $BG
@onready var component_control: ComponentControl = $ComponentControl
@onready var currency_display: CurrencyDisplay = $CurrencyDisplay
var budget: int
@export var shop_loot: LootTable


func _ready() -> void:
	budget = Global.player_currency
	var available := shop_loot.get_loot(
		randi_range(3, 5) - randi_range(0, 1),
		Global.player_ship.get(&"Luck").value)
	
	component_control.start(available, Global.player_ship)


func _on_bg_draw() -> void:
	var vrect: Rect2 = get_viewport_rect()
	bg.draw_rect(Rect2(-vrect.size / 2, vrect.size), BG_COLOUR)
	
	for i in 256:
		var pos: Vector2 = vrect.size * Vector2(randf(), randf()) - vrect.size / 2
		bg.draw_circle(pos, 1, Color.WHITE)


func _on_component_control_reprocessed() -> void:
	pass # Replace with function body.


func _on_component_control_swap_amount(value: int) -> void:
	budget += value
	currency_display.apply_amount(budget)


func _on_component_control_continue_pressed() -> void:
	if budget < 0:
		# Declined animation
		pass
	else:
		# Accepted animation:
		# Switch to map
		pass

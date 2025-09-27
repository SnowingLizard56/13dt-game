class_name ShopController extends Control

const BG_COLOUR: Color = Color(0.059, 0.106, 0.149, 1.0)
const PLAYER_COLOUR: Color = Color(0.125, 0.647, 0.651, 1.0)
const SOLID_COLOUR: Color = Color(0.961, 0.91, 0.82, 1.0)
const ENEMY_COLOUR: Color = Color(0.867, 0.337, 0.224, 1.0)
const MONEY_SHAKE_SPEED: float = 5 * TAU
const MONEY_SHAKE_AMPLITUDE: float = 10.0
const FADE_IN_TIME: float = 0.5

@onready var bg: Control = $BG
@onready var component_control: ComponentControl = $ComponentControl
@onready var currency_display: CurrencyDisplay = $CurrencyDisplay
@onready var delta_money: Control = $DeltaMoney
@onready var currency_position: Vector2 = $CurrencyDisplay.position
@onready var fade_in: ColorRect = $FadeIn

var budget: int
@export var shop_loot: LootTable
var shake_money := 0.0:
	set(v):
		if v > shake_money:
			shake_money_max = v
		shake_money = v

var shake_money_max := 0.0


func _ready() -> void:
	budget = Global.player_currency
	currency_display.apply_amount(budget)
	var available := shop_loot.get_loot(
		randi_range(3, 5) - randi_range(0, 1),
		Global.player_ship.get(&"Luck").value)
	
	component_control.start(available, Global.player_ship)
	var t := get_tree().create_tween()
	t.tween_property(fade_in, "modulate", Color(1, 1, 1, 0), FADE_IN_TIME)
	t.tween_callback(fade_in.hide)


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
		shake_money = 0.8
	else:
		# Accepted animation:
		# Switch to map
		# TODO
		pass


func _on_component_control_focused(what: ShipComponentNode, is_left: bool) -> void:
	if is_left:
		delta_money.apply_amount(what.swap_cost)
	else:
		delta_money.apply_amount(-what.swap_cost)


func _process(delta: float) -> void:
	if shake_money:
		shake_money = max(shake_money - delta, 0)
	currency_display.position = currency_position\
		+ shake_money * MONEY_SHAKE_AMPLITUDE * Vector2(
		sin(MONEY_SHAKE_SPEED * (shake_money_max - shake_money))
		, 0)

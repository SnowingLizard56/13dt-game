extends Control

@onready var hp_bar: ProgressBar = $HealthBar/Health
@onready var buffer_bar: ProgressBar = $HealthBar/Buffer
@onready var currency_display: CurrencyDisplay = $"CurrencyDisplay"
@onready var xp_display: ProgressBar = $UpgradeBar/ProgressBar
@onready var component_control: ComponentControl = $"ComponentControl"
@onready var player: Player = %Player
@export var loot_table: LootTable


var hp_tween: Tween
var xp_tween: Tween


func _ready() -> void:
	Global.level_up.connect(give_level_up_reward)


func update_health(ship: Ship):
	hp_bar.value = ship.hp
	
	if hp_tween:
		hp_tween.kill()
	hp_tween = get_tree().create_tween()
	hp_tween.tween_interval(0.5)
	hp_tween.tween_property(buffer_bar, "value", ship.hp, 0.1)


func set_health(ship: Ship):
	hp_bar.max_value = ship.max_hp
	buffer_bar.max_value = ship.max_hp
	hp_bar.value = ship.hp
	buffer_bar.value = ship.hp


func update_all():
	update_health(Global.root.player.ship)
	currency_display.apply_amount(Global.player_currency)


func add_xp(v: float):
	const MINIMUM := 100.0
	const POINT_X := 100.0
	const POINT_Y := 1000.0
	
	var cutoff = (POINT_Y - MINIMUM) / POINT_X * Global.player_level + MINIMUM
	if cutoff - Global.player_xp < v:
		Global.player_xp += v - cutoff
		Global.player_level += 1
		Global.level_up.emit()
	else:
		Global.player_xp += v
	
	update_xp_display(Global.player_xp, cutoff)


func update_xp_display(val: float, maxval: float):
	const UPDATE_TIME := 0.2
	
	xp_display.max_value = maxval
	
	if xp_tween:
		xp_tween.kill()
	xp_tween = get_tree().create_tween()
	xp_tween.tween_property(xp_display, "value", val, UPDATE_TIME)


func give_level_up_reward():
	var cmpnts := loot_table.get_loot(1, player.ship.get(&"Luck").value)
	get_tree().paused = true
	component_control.start(cmpnts, player.ship)
	component_control.show()
	component_control.modulate.a = 0
	# Completely offscreen
	component_control.for_moving.position = Vector2(0, 648)
	
	var t: Tween = get_tree().create_tween()
	t.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	t.tween_property(component_control, "modulate", Color.WHITE, 0.3)
	t.parallel().tween_property(component_control.for_moving, "position", Vector2.ZERO, 1.0).set_trans(Tween.TRANS_QUAD)



func _process(delta: float) -> void:
	if Input.is_action_just_pressed("test"):
		give_level_up_reward()


func level_up_finalised() -> void:
	component_control.finish()
	var t: Tween = get_tree().create_tween()
	t.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	t.tween_property(component_control, "modulate", Color(1, 1, 1, 0), 0.3)
	t.parallel().tween_property(component_control.for_moving, "position", Vector2(0, 648), 1.0).set_trans(Tween.TRANS_QUAD)
	t.tween_callback(component_control.hide)
	t.tween_callback(get_tree().set.bind(&"paused", false))

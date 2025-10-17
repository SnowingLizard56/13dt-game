class_name EventEffect extends Resource

@export var title: String
@export var _console: String
@export_category("Health")
## Proportion of max health gained or lost between -1 and 1.
@export var health_prop: float = 0.0
## Flat health gained or lost.
@export var health_change: float = 0.0
@export_category("E127")
## Change in e127. Can be negative.
@export var money: int = 0
@export_category("ShipComponents")
## Tables to be rolled on. 
@export var component_list: Array[LootTable] = []
@export_category("Random Effects")
## Random Effects
@export var effects: Array[EventEffect] = []
## Weights for the random effects
@export var weights: Array[float] = []
@export_category("Next Event")
## Next Event
@export var next_event: MapEvent = null


var has_components: bool:
	get():
		return component_list != []


func get_components() -> Array[ShipComponent]:
	var out: Array[ShipComponent] = []
	for i in component_list:
		out += i.get_loot(1, Global.player_ship.get(&"Luck").value)
	return out


func apply(map_ui: MapUI, ship: Ship) -> MapEvent:
	if _console:
		print(_console)
	var output: MapEvent = next_event
	# Health
	ship.hp += ship.max_hp * health_prop
	ship.hp += health_change
	if ship.hp <= 0:
		ship.hp = 1.0
	elif ship.hp > ship.max_hp:
		ship.hp = ship.max_hp
	map_ui.update_hp()
	
	# E127
	map_ui.change_currency(money)
	
	# Event
	var other_event: MapEvent = null
	if effects:
		other_event = effects[Global.random.rand_weighted(weights)].apply(map_ui, ship)
	if other_event:
		output = other_event
	return output

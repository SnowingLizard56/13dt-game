class_name LootTable extends Resource

@export var weight: float = 1
@export var table: Array[LootTable] = []
@export var component: ShipComponent


func get_loot(count: int, luck: float = 1) -> Array[ShipComponent]:
	assert(table or component, "Loot table needs either another table or a component.")
	if table:
		if 100 ** (1.0 / luck) == INF:
			var max_item := LootTable.new()
			for t in table:
				if t.weight > max_item.weight:
					max_item = t
			return max_item.get_loot(count, 0)
		var weights: PackedFloat32Array = []
		for t in table:
			weights.append(t.weight ** (1.0 / luck))
		var output: Array[ShipComponent] = []
		for i in count:
			output.append_array(table[Global.random.rand_weighted(weights)].get_loot(1, luck))
		return output
	return [component]

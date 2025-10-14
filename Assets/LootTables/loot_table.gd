class_name LootTable extends Resource

@export var weight: float = 1
@export var table: Array[LootTable] = []
@export var component: ShipComponent


func get_loot(count: int, luck: float = 1) -> Array[ShipComponent]:
	if table:
		if 100 ** (1.0 / luck) == INF:
			var max_item := LootTable.new()
			max_item.weight = 0
			for table2 in table:
				if table2.weight > max_item.weight:
					max_item = table2
			return max_item.get_loot(count, 0)
		var weights: PackedFloat32Array = []
		for table2 in table:
			weights.append(table2.weight ** (1.0 / luck))
		var output: Array[ShipComponent] = []
		for i in count:
			output.append_array(table[Global.random.rand_weighted(weights)].get_loot(1, luck))
		return output
	return [component.duplicate(true)]

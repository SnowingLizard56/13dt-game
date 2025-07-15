extends TriggerComponent


func _trigger(player: Player, ship: Ship):
	if !trigger_ready:
		return
	#player.add_child()
	super(player, ship)

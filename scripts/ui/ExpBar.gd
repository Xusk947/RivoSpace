extends ProgressBar
class_name EnergyBar

var player:Unit

func _process(delta):
	if player:
		value = player.energy
		max_value = player.max_energy
	else:
		player = GameManager.get_player()

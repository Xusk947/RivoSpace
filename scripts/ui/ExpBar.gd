extends ProgressBar
class_name EnergyBar

onready var bar = $ProgressBar

var player:Unit

func _process(delta):
	if player:
		value = player.energy
		max_value = player.max_energy
		bar.value = value
		bar.max_value = max_value
	else:
		player = GameManager.get_player()

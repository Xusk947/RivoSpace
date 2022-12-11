extends ProgressBar
class_name HealthBar

var player:Unit # Our player Unit

func _ready():
	min_value = 0
	max_value = 1
	step = 0.001 # Minimum step

func _process(_delta):
	if not player: 
		_update_player()
		return
	if player.killed:
		_update_player()
		return
	# Calculate value of current Health / Max Calculated Health
	value = player.health / (player.max_health * player.card.health_multiplayer)
	
func _update_player():
	# If player die or not exist
	player = GameManager.get_player()

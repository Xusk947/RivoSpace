extends ProgressBar
class_name HealthBar

var player:Unit # Our player Unit
onready var bar:ProgressBar = $ProgressBar

func _ready():
	min_value = 0
	max_value = 1
	step = 0.001 # Minimum step
	bar.max_value = max_value
	bar.min_value = min_value
	bar.step = step

func _process(_delta):
	if not player: 
		_update_player()
		return
	if player.killed:
		_update_player()
		return
	# Calculate value of current Health / Max Calculated Health
	value = player.health / (player.max_health * player.card.health_multiplayer)
	bar.value = value
func _update_player():
	# If player die or not exist
	player = GameManager.get_player()

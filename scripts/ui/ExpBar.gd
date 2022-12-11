extends ProgressBar
class_name ExpBar

func _ready():
	Events.connect("expiriance_gained", self, "_expiriance_gained") # When player get Expiriance Update EXP_Bar
	Events.connect("level_up", self, "_level_up") # But When player level_up we change max_expiriance and current_expiriance value
	max_value = GameManager.scene_holder.expiriance_max_progress

func _expiriance_gained(event):
	value = event.expiriance

func _level_up(event):
	value = event.current_expiriance
	max_value = event.max_expiriance

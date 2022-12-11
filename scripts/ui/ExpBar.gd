extends ProgressBar



func _ready():
	Events.connect("expiriance_gained", self, "_expiriance_gained")
	
func _expiriance_gained(event):
	max_value = event.max_expiriance
	value = event.expiriance

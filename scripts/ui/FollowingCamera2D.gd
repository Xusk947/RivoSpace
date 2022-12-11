extends Camera2D
class_name FollowingCamera2D

var _target:Node2D

func _ready():
	GameManager.camera = self
	smoothing_enabled = true
	smoothing_speed = 5

func _process(delta):
	if _target == null:
		_target = GameManager.get_player()
	else:
		if _target.is_inside_tree():
			position = lerp(position, _target.position, smoothing_speed / 100)
		else:
			_target = null

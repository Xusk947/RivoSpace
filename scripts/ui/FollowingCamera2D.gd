extends Camera2D
class_name FollowingCamera2D

var _target:Node2D
var _scale_target:float = 1

func _ready():
	GameManager.camera = self
	smoothing_enabled = true
	smoothing_speed = 5

func _process(delta):
	if _target:
		if _target.is_inside_tree():
			position = lerp(position, _target.global_position, smoothing_speed / 100)
			zoom = lerp(zoom, Vector2(_scale_target, _scale_target), smoothing_speed / 100)
		else:
			_target = null

func set_target(node:Node2D, scale:float = 1):
	_target = node
	_scale_target = scale

extends ParallaxBackground

onready var background:ParallaxLayer = $Background
onready var star_dust:ParallaxLayer = $StarDust
onready var stars:ParallaxLayer

export var gradient:Gradient
export var gradien_distance:float = 1024

var _pos:Vector2

func _process(delta):
	if GameManager.get_player():
		_pos = GameManager.get_player().position
		var offset = int(_pos.x) % 1024 / 1024.0
		star_dust.modulate = gradient.interpolate(gradient.get_offset(offset))

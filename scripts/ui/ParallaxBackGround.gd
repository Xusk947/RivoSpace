extends ParallaxBackground

onready var background:ParallaxLayer = $Background
onready var star_dust:ParallaxLayer = $StarDust
onready var stars_slow:ParallaxLayer = $StarsSlow

export var gradient:Gradient
export var gradien_distance:float = 1024

var _pos:Vector2
var _stars:Array

func _ready():
	_stars = []
	for child in stars_slow.get_children():
		_stars.append(child)

func _process(delta):
	if GameManager.get_player():
		_pos = GameManager.get_player().position
		var offset = int(_pos.x) % 1024 / 1024.0
		star_dust.modulate = gradient.interpolate(_pos.x)
	for star in _stars:
		if star is Sprite:
			star.rotate(delta * randf() / 100)

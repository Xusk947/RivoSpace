extends Node2D
class_name VanishingText

onready var label:Label = $Label
var vanish_time:float = 1
var adding_size:float = 1
var _time:float = 0

func _ready():
	_time = vanish_time
	label.self_modulate.a = 1
	adding_size = 1
	scale = Vector2(1, 1)

func _process(delta):
	_time -= delta
	var perc = _time / vanish_time
	label.self_modulate.a =  perc
	scale = Vector2(perc + adding_size * _time, perc + adding_size * _time)
	if _time < 0:
		remove()

func remove():
	Pool.return_node(self)

func add():
	if GameManager.scene_holder:
		GameManager.scene_holder.add_child(self)

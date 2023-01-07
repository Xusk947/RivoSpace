tool
extends ParallaxBackground

onready var background:ParallaxLayer = $Background
onready var star_dust:ParallaxLayer = $StarDust
onready var stars_slow:ParallaxLayer = $StarsSlow

export var gradient:Gradient
export var gradien_distance:float = 1024

export var material:Material setget _set_material, _get_material
export var modulate:Color setget _set_modulate, _get_modulate
export var opacity:float setget _set_opacity, _get_opacity

var _pos:Vector2
var _stars:Array

func _ready():
	_stars = []
	for child in stars_slow.get_children():
		_stars.append(child)
		
func _set_modulate(v):
	modulate = v
	material.set("shader_param/color", v)

func _get_modulate():
	return modulate

func _set_opacity(v):
	opacity = v
	material.set("shader_param/hit_opacity", v)

func _get_opacity():
	return opacity

func _set_material(v:Material):
	material = v.duplicate()
	for child in get_children():
		child.material = material

func _get_material():
	return material

tool
extends ParallaxBackground

onready var background:ParallaxLayer = $Background

export var gradient:Gradient
export var gradien_distance:float = 1024

export var material:Material setget _set_material, _get_material
export var modulate:Color setget _set_modulate, _get_modulate
export var opacity:float setget _set_opacity, _get_opacity

export var slow_stars_scroll:float = 0.2
export var second_stars_scroll:float = 0.4
export var fast_stars_scroll:float = 0.9
export var star_dust_scroll:float = 0.35
export var second_star_dust_scroll:float = 0.15
# Every Sprite must be 1024*1024
export (Array, Texture) var stars
export (Array, Texture) var dust
export (Array, Texture) var dark_dust

var _pos:Vector2
var _stars:Array

func _ready():
	background.material = material
	add_child(_get_parallax_layer(ArrayTools.select_random(stars), "SlowStars", slow_stars_scroll))
	add_child(_get_parallax_layer(ArrayTools.select_random(dark_dust), "SecondStarDust", second_star_dust_scroll))
	add_child(_get_parallax_layer(ArrayTools.select_random(dust), "StarDust", star_dust_scroll))
	add_child(_get_parallax_layer(ArrayTools.select_random(stars), "SecondStars", second_stars_scroll))
	add_child(_get_parallax_layer(ArrayTools.select_random(stars), "FastStars", fast_stars_scroll))

func _get_parallax_layer(tex:Texture, name:String, move_scale:float, mirroring:int = 3073):
	var parallax_layer = ParallaxLayer.new()
	var sprite = Sprite.new()
	sprite.texture = tex
	sprite.centered = false
	sprite.use_parent_material = true
	parallax_layer.name = name
	parallax_layer.material = material
	parallax_layer.add_child(sprite)
	parallax_layer.motion_mirroring = Vector2(mirroring, mirroring)
	parallax_layer.motion_scale = Vector2(move_scale, move_scale)
	return parallax_layer

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

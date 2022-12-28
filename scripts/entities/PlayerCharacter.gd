extends KinematicBody2D
class_name PlayerCharacter

onready var engine:Sprite = $Engine

var velocity:Vector2
var unit:Unit # With which unit entter in the ship
var zone:Sprite # Zone says Unit ship 
var can_exit:bool # Unit will be deleted in ShipHub when it's true
var is_moving:bool
var _engine_scale:float
var _need_scale:float
func _ready():
	can_exit = false
	is_moving = false
	velocity = Vector2.ZERO

func _physics_process(delta):
	_engine_scale = lerp(_engine_scale, _need_scale, 0.025)
	if _engine_scale > 1.10:
		_need_scale = 0.75
	elif _engine_scale < 0.9:
		_need_scale = 1.25
	for child in get_children():
		if child is Sprite:
			if child.name == "Body": continue
			child.scale.x = _engine_scale
			child.modulate = unit.team
			child.scale.y = child.scale.x
	# Basic Movement
	var dir = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down"))
	velocity = dir * 50 * delta * 60
	velocity = move_and_slide(velocity)
	is_moving = velocity != Vector2.ZERO
	if is_moving:
		rotation = Angles.move_toward(rotation, velocity.angle() + 1.5708, deg2rad(5))
		
	# When unit close to him ship it's start disappearing animation
	if position.distance_squared_to(zone.position) < 500:
		if modulate.a > 0:
			modulate.a = lerp(modulate.a, 0, 0.1)
			can_exit = modulate.a < 0.001
	elif modulate.a < 1:
		modulate.a = lerp(modulate.a, 1, 0.2)

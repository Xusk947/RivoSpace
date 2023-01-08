extends KinematicBody2D
class_name PlayerCharacter

onready var engines:Node2D = $Engines

var velocity:Vector2
var unit:Unit # With which unit entter in the ship
var zone:Sprite # Zone says Unit ship 
var ship_hub # Ship Hub, who spawn this Character
var can_exit:bool # Unit will be deleted in ShipHub when it's true
var is_moving:bool # For Engine?
# --- ENGINE ANIMATION
var _engine_scale:float # Current Engine Scale
var _need_scale:float # Prefer Engine Scale
var _engine_sprites:Array

var _inited:bool = false
var _display_showed:bool = false

func _ready():
	can_exit = false
	is_moving = false
	velocity = Vector2.ZERO
	if _inited: return
	for child in engines.get_children():
		_engine_sprites.append(child)

func _physics_process(delta):
	_engine_scale = lerp(_engine_scale, _need_scale, 0.025)
	if _engine_scale > 1.10:
		_need_scale = 0.75
	elif _engine_scale < 0.9:
		_need_scale = 1.25
	for engine in _engine_sprites:
		engine.scale.x = _engine_scale
		engine.modulate = unit.team
		engine.scale.y = engine.scale.x
	if ship_hub.path_map.visible:
		return
	# Basic Movement
	var dir = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down"))
	velocity = dir * 50 * delta * 60
	velocity = move_and_slide(velocity)
	is_moving = velocity != Vector2.ZERO
	# Rotate Player Character when it moving
	if is_moving:
		global_rotation = Angles.move_toward(global_rotation, velocity.angle() + 1.5708, deg2rad(5))
	# Display Port
	var dst = position.distance_squared_to(ship_hub.display.position)
	if not _display_showed && dst < 500:
		ship_hub.path_map.show()
		_display_showed = true
	elif dst > 600:
		_display_showed = false
	if ship_hub.unit_owner.moving:
		GameManager.camera.position = global_position
	# When unit close to him ship it's start disappearing animation
	if position.distance_squared_to(zone.position) < 500:
		if modulate.a > 0:
			modulate.a = lerp(modulate.a, 0, 0.1)
			can_exit = modulate.a < 0.001
	elif modulate.a < 1:
		modulate.a = lerp(modulate.a, 1, 0.2)

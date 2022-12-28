extends KinematicBody2D
class_name PlayerCharacter

var velocity:Vector2
var unit:Unit # With which unit entter in the ship
var zone:Sprite
var can_exit:bool
func _ready():
	can_exit = false
	velocity = Vector2.ZERO

func _physics_process(delta):
	var dir = Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down"))
	velocity = dir * 50 * delta * 60
	velocity = move_and_slide(velocity)
	if velocity != Vector2.ZERO:
		rotation = Angles.move_toward(rotation, velocity.angle() + 1.5708, deg2rad(5))
	if position.distance_squared_to(zone.position) < 500:
		if modulate.a > 0:
			modulate.a = lerp(modulate.a, 0, 0.1)
			can_exit = modulate.a < 0.001
	elif modulate.a < 1:
		modulate.a = lerp(modulate.a, 1, 0.2)

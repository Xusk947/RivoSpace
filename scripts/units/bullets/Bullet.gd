extends Node2D
class_name Bullet

export(Resource) var type
var unit:Unit
var damage_multiplayer:float = 1.0
var crit:bool = false

var _time:float = 0
var _speed:float = 0
var velocity:Vector2 = Vector2()
var piercing:int = 0

var _initialized:bool = false

func _ready():
	_time = type.lifetime
	if _initialized: return
	if type is BulletType:
		$Sprite.texture = type.texture
		# Automaticlly Set Collision Shape for sprites
		#var shape = $Area2D/CollisionShape2D.shape
		#if shape is RectangleShape2D:
		#	shape.extents = Vector2(type.texture.get_width() * $Sprite.scale.x, type.texture.get_height() * $Sprite.scale.y)
		_speed = type.speed
		$Area2D.connect("body_shape_entered", self, "_collision")
	_initialized = true
func _collision(_rid:RID, body:Node, body_shape_idx, _local_shape_idx):
	if (body is PhysicsBody2D):
		var owner:Node2D = body.shape_owner_get_owner(body_shape_idx)
		var parent = owner.get_parent()
		if (parent is Unit):
			if not (parent.team == unit.team):
				parent.apply_damage(type.damage * damage_multiplayer)
				if unit:
					if unit.team:
						var p:VanishingText = Pool.take_node(Res.vanishing_text)
						p.position = global_position + Vector2(rand_range(-50, 50), rand_range(-50, 50))
						p.add()
						if crit:
							p.adding_size = 1.25
						p.modulate = Color.red
						p.modulate = unit.team
						p.label.text = String(type.damage * damage_multiplayer)
				if piercing < 1:
					kill()
				piercing -= 1
				
# Move bullet
func _physics_process(delta):
	_time -= delta * 60
	if _time < 0:
		kill()
	position += velocity

func add():
	if GameManager.scene_holder:
		GameManager.scene_holder.add_child(self)
# Kill bullet and return to Pool
func kill():
	remove()
	return
	if type.hit_fx:
		var fx:Fx = Pool.take_node(type.hit_fx)
		fx.position = global_position
		fx.rotation = global_rotation
		fx.color = unit.team
		fx.add()
# Return to Pool
func remove():
	Pool.return_node(self)

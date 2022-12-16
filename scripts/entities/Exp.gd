extends Area2D
class_name Exp

var given:float = 10
var heal_boost:float = 0
var move_speed:float = 5

var player:Unit
var _initialized:bool

func _ready():
	if _initialized: return
	collision_layer = 0b0010
	collision_mask = 0b0000
	connect("body_shape_entered", self, "_collision")
	_initialized = true

func _collision(_rid:RID, body:Node, body_shape_idx, _local_shape_idx):
	if (body is Unit and body.controller is Player):
		apply(body)

func _process(delta):
	var player = GameManager.get_player()
	if player:
		position = position.move_toward(player.position, delta * 60 * move_speed)

func apply(unit:Unit):
	unit.health += heal_boost
	if GameManager.scene_holder is GameScene:
		GameManager.scene_holder.add_expiriance(given)
	remove()

func remove():
	Pool.return_node(self)

func add():
	call_deferred("_add")
# Remove Deffered Error / Spawn Exp in next game frame
func _add():
	if GameManager.scene_holder:
		GameManager.scene_holder.add_child(self)

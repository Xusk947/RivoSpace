extends KinematicBody2D
class_name Unit

export var max_health:float = 310
export var move_speed:float = .1
export var max_speed:float = 3
export var rotation_speed:float = 3
export var regeneration:float = 0
export(Script) var controller_script: Script setget _set_controller_script, _get_controller_script

var velocity:Vector2 = Vector2() # every frame move unit
var aim:Vector2 = Vector2() # current unit aiming

var can_shoot:bool = false # if unit can't shoot weapons will not shooting
var moving:bool = false setget _set_moving, _get_moving # says us unit is moving or no
var rotation_dir:float # from -1 to 1 describe current unit rotation angle
var team:Color = Color.white setget _set_team, _get_team

var sprite_name:String

onready var body:Sprite = $Body # Main Sprite
onready var shape:CollisionShape2D = $Shape # Collision Shape

onready var _weapon_holder:Node2D = $WeaponHolder # Holder for all weapons
onready var _thruster_holder:Node2D = $ThrusterHolder # Holder for all Thruster Fx

var outline:Sprite
var health:float setget _set_health, _get_health
var target:Unit
var weapons:Array
var killed:bool = false
var controller # Controll all unit movements shooting
var card:Card

var _inited:bool

func _ready():
	killed = false
	if _inited: return
	_create_constructor()
	_init_outline()
	_init_weapon()
	_inited = true

func _create_constructor():
	health = max_health
	
func _init_outline():
	var file = File.new()
	if file.file_exists("res://sprites/units/" + name + "-outline.png"):
		outline = Sprite.new()
		outline.texture = load("res://sprites/units/" + name + "-outline.png")

func _init_weapon():
	var children = _weapon_holder.get_children()
	weapons = []
	for child in children:
		weapons.append(child)
		child.unit = self

func _physics_process(delta):
	velocity = move_and_slide(velocity * delta * 60)
	health += (regeneration + card.regeneration_speed) * card.regeneration_multiplayer
	var max_calculated_speed:float = max_speed * card.movement_speed_multiplayer
	velocity.x = clamp(velocity.x, -max_calculated_speed, max_calculated_speed)
	velocity.y = clamp(velocity.y, -max_calculated_speed, max_calculated_speed)
	velocity *= 0.998
# Abstract Void
func _update_controller(_delta):
	pass
# TODO: Finish it
func _update_thrusters(_delta):
	pass

func rotate_to(angle:float, rot_speed:float):
	var old_rotation = rotation
	rotation = Angles.move_toward(rotation, angle, rot_speed)
	rotation_dir = Mathf.mod(old_rotation, Angles.PI2) - rotation
	
#Rotate ship to point with some speed
func rotate_to_point(pos:Vector2, rot_speed:float):
	var old_rotation = rotation
	rotation = Angles.move_toward(rotation, position.angle_to_point(pos) - 1.5708, rot_speed * card.rotation_speed_mutliplayer)
	rotation_dir = Mathf.mod(old_rotation, Angles.PI2) - rotation

# change outline color when unit is other team
func _change_outline_color(to:Color = team):
	if outline:
		outline.modulate = to
# Change All thruster Emitting to value
func _change_thruster_emitting(to:bool = false):
	if not _thruster_holder: return
	for thruster in _thruster_holder.get_children():
		thruster.emitting = to
# Restart All thrusters, thats disable Global Fx showing when taked from pool again
func _restart_thrusters():
	if not _thruster_holder: return
	for thruster in _thruster_holder.get_children():
		thruster.restart()
# Change Thruster color if this need it
func _change_thruster_color(to:Color = team):
	if not _thruster_holder: return
	for thruster in _thruster_holder.get_children():
		thruster.color = to
# idk why
func _change_thruster_direction(dir:float = 0):
	if not _thruster_holder: return
	for thruster in _thruster_holder.get_children():
		thruster.orbit_velocity = dir
# Moving Unit by self rotation
func move_by_rotation():
	velocity += Vector2(move_speed * card.movement_speed_multiplayer, 0).rotated(rotation - 1.5708)

func apply_damage(damage:float):
	health -= damage
	if health < 0:
		kill()

func set_process(value:bool):
	.set_process(value)
	can_shoot = value
	moving = value
	if controller:
		controller.set_process(value)

func set_physics_process(value:bool):
	.set_physics_process(value)
	if controller:
		controller.set_physics_process(value)

# Add/Remove from tree Region
func spawn():
	pass

func add():
	if GameManager.scene_holder != null:
		GameManager.scene_holder.add_child(self)
		if controller:
			controller.on_add()

func kill():
	var fx:Fx = Pool.take_node(Res.death_fx)
	fx.position = global_position
	#fx.set_color(team)
	fx.add()
	if controller:
		controller.on_kill()
	GameManager.play_sound(Res.unit_death_fx[rand_range(0, len(Res.unit_death_fx))])
	remove()

func remove():
	_restart_thrusters()
	velocity = Vector2()
	position = Vector2.INF
	killed = true
	target = null
	health = max_health
	if controller:
		controller.on_remove()
	Pool.return_node(self)

# --- Getters Setters Area ---
func _set_controller_script(v:Script):
	if not controller:
		controller = Node2D.new()
		controller.name = "Controller"
		add_child(controller)
	controller.set_script(v)
	controller.unit = self

func _get_controller_script() -> Script:
	return controller.get_script()

func _get_moving() -> bool:
	return moving

func _collision(_rid:RID, body:Node, body_shape_idx, _local_shape_idx):
	if body is KinematicBody2D:
		if "Unit" in body:
			body.health -= 10

func _set_moving(v:bool):
	moving = v
	_change_thruster_emitting(v)

func _get_health():
	return health
	
func _set_health(v):
	health = v
	health = clamp(health, -1, max_health * card.health_multiplayer)

func _set_team(v:Color):
	team = v
	card = GameManager.get_card(v)
	print(v,":",card)
	_change_thruster_color()

func _get_team() -> Color:
	return team

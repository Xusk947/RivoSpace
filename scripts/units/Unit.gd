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

var outline:Sprite # TODO: Fix it, and make auto outline generator in external app
var health:float setget _set_health, _get_health
var target:Unit
var weapons:Array # Array of all weapons (Sprite with Weapon Script)
var killed:bool = false # Only kill() set this parameter to True
var controller # Controll all unit movements shooting
var card:Card # Thats parameter says to unit which card it used

var _inited:bool # To Call constructor only once

func _ready():
	killed = false
	if _inited: return
	_create_constructor()
	_init_outline()
	_init_weapon()
	_inited = true
# For future
func _create_constructor():
	health = max_health
# Load outline from Sprite if sprite.name + "-outline" exist
func _init_outline():
	var outline_sprite_new = Sprite.new()
	var path = self.body.texture.resource_path
	path = path.replace(".png", "-outline.png")
	var file = File.new()
	if file.file_exists(path):
		outline_sprite_new.texture = load(path)
		outline_sprite_new.rotation_degrees = 90
		outline_sprite_new.offset = body.offset
		outline = outline_sprite_new
		add_child_below_node(body, outline)
# Add all weapons in Weapon Holder Node to Array
func _init_weapon():
	var children = _weapon_holder.get_children()
	weapons = []
	for child in children:
		weapons.append(child)
		child.unit = self

func _physics_process(delta):
	# Movement Friction, so that unit does not move indefinitely with it velocity 
	velocity *= 0.998
	# Moving unit haha
	velocity = move_and_slide(velocity * delta * 60)
	# Regenerate health every physics frame
	self.health += (regeneration + card.regeneration_speed) * card.regeneration_multiplayer
	# Calculate max_speed with card parameter
	var max_calculated_speed:float = max_speed * card.movement_speed_multiplayer
	# Clamp Velocity to max_speed
	velocity.x = clamp(velocity.x, -max_calculated_speed, max_calculated_speed)
	velocity.y = clamp(velocity.y, -max_calculated_speed, max_calculated_speed)
# Abstract Void
func _update_controller(_delta):
	pass
# TODO: Finish it, add rotation fx, and thruster which enables only when unit rotating
func _update_thrusters(_delta):
	pass
# Rotate to Specific Angle with given rotation speed
func rotate_to(angle:float, rot_speed:float):
	var old_rotation = rotation
	rotation = Angles.move_toward(rotation, angle, rot_speed)
	rotation_dir = Mathf.mod(old_rotation, Angles.PI2) - rotation
	
# Rotate ship to point with given rotation speed
func rotate_to_point(pos:Vector2, rot_speed:float):
	var old_rotation = rotation
	rotation = Angles.move_toward(rotation, position.angle_to_point(pos) - 1.5708, rot_speed * card.rotation_speed_mutliplayer)
	rotation_dir = Mathf.mod(old_rotation, Angles.PI2) - rotation

# Change outline color when unit team is changed
func _change_outline_color(to:Color = team):
	if outline: # Check if unit has outline
		outline.self_modulate = to
# Change All thruster Emitting to value
func _change_thruster_emitting(to:bool = false):
	if not _thruster_holder: return # If Unit doen't have any thruster we return
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
# TODO: Make it working xD, set some orbit velocity when unit rotating
func _change_thruster_direction(dir:float = 0):
	if not _thruster_holder: return
	for thruster in _thruster_holder.get_children():
		thruster.orbit_velocity = dir
# Moving Unit by self rotation and calculated speed
func move_by_rotation():
	velocity += Vector2(move_speed * card.movement_speed_multiplayer, 0).rotated(rotation - 1.5708)
# Apply Damage, and check if unit can die
func apply_damage(damage:float):
	health -= damage
	if health < 0:
		kill()
# When we disable unit we need to disable controller too
func set_process(value:bool):
	.set_process(value)
	can_shoot = value
	moving = value
	if controller:
		controller.set_process(value)
# Disable controller physics_process with unit
func set_physics_process(value:bool):
	.set_physics_process(value)
	if controller:
		controller.set_physics_process(value)

# Add/Remove from tree Region
func spawn():
	pass # TODO: Make Spawn Animation
# Add Unit to GameScene
func add():
	if GameManager.scene_holder != null:
		GameManager.scene_holder.add_child(self)
		if controller:
			controller.on_add()
# Kill unit with Kill Fx
func kill():
	var fx:Fx = Pool.take_node(Res.death_fx)
	fx.position = global_position
	#fx.set_color(team) TODO: Create variable death_fx_colored_to_team or smth like that
	fx.add()
	# Call controller on_kill() function when it die, to remove Unit from some Array, or space EXP
	if controller:
		controller.on_kill()
	# Play death sound when unit die
	GameManager.play_sound(Res.unit_death_fx[rand_range(0, len(Res.unit_death_fx))])
	remove()

func remove():
	_restart_thrusters()
	velocity = Vector2()
	position = Vector2.INF # Set Position to INF, cuz when unit taked from Pool, body start collide without it
	killed = true
	target = null # Remove target
	health = max_health * card.health_multiplayer # Calculate Specific Health Parameters
	if controller: # Check if controller exist
		controller.on_remove() # Call controller function on_remove() 
	Pool.return_node(self) # Return Unit to Object Pool

# --- Getters Setters Area ---
func _set_controller_script(v:Script):
	# When unit doesn't have controller Node we create ot
	if not controller:
		controller = Node2D.new()
		controller.name = "Controller"
		add_child(controller)
	# Then set controller script to this node
	controller.set_script(v)
	controller.unit = self # Set Controller unit for it self

func _get_controller_script() -> Script:
	return controller.get_script()

func _set_moving(v:bool):
	moving = v
	# Disable Thrusters when unit stop moving
	_change_thruster_emitting(v)

func _get_moving() -> bool:
	return moving

# TODO: Add Area2D to Unit and when it collide with another unit damage enemy, and them self too
func _collision(_rid:RID, body:Node, body_shape_idx, _local_shape_idx):
	if body is KinematicBody2D:
		if "Unit" in body:
			body.health -= 0

func _get_health():
	return health
# We clamp health to our calculated max_health at maximum point and -1 minimum, cuz unit MUST DIE!  
func _set_health(v):
	health = clamp(v, -1, max_health * card.health_multiplayer)
# When change Unit Team 
func _set_team(v:Color):
	team = v
	# Take TeamCard from GameManager Cards
	card = GameManager.get_card(v)
	# Change Thruster emitting, Outline Sprite color to team color
	_change_thruster_color()
	_change_outline_color()

func _get_team() -> Color:
	return team

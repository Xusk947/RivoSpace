extends Resource
class_name Card
# --- Display Data ---
# Using only when card drawing in Scene 
export var texture:Texture
export var name:String
export var description:String
export var modulate_color:Color = Color.white
export var recursive:bool = true
# --- Base Parameters ---
export var health_multiplayer:float = 1.0 # Unit Defense
export var regeneration_speed:float = 0
export var regeneration_multiplayer:float = 1.0
export var armor_multiplayer:float = 1.0
export var damage_gain_multiplayer:float = 1.0
export var movement_speed_multiplayer:float = 1.0 # Movement
export var rotation_speed_mutliplayer:float = 1.0
export var body_damage_multiplayer:float = 1.0 # Damage
# --- Bullets
export var crit_chance:float = 0.0
export var crit_multiplayer:float = 1.0
export var weapon_shoot_cone_adding:float = 0
export var bullet_damage_multiplayer:float = 1.0
export var bullet_pricing:int = 0
export var bullet_adding:int = 0
# --- Drone Area
export var max_drones:int = 1
export var drones_build_time_speed_multiplayer:float = 1.0

func add(card:Card):
	health_multiplayer += card.health_multiplayer
	regeneration_multiplayer += card.regeneration_multiplayer
	regeneration_speed += card.regeneration_speed
	armor_multiplayer += card.armor_multiplayer
	damage_gain_multiplayer += card.damage_gain_multiplayer
	movement_speed_multiplayer += card.movement_speed_multiplayer
	rotation_speed_mutliplayer += card.rotation_speed_mutliplayer
	body_damage_multiplayer += card.body_damage_multiplayer
	# --- Bullets
	crit_chance += card.crit_chance
	crit_multiplayer += card.crit_multiplayer
	weapon_shoot_cone_adding += card.weapon_shoot_cone_adding
	bullet_damage_multiplayer += card.bullet_damage_multiplayer
	bullet_pricing += card.bullet_pricing
	bullet_adding += card.bullet_adding
	# --- Drones
	max_drones += card.max_drones
	drones_build_time_speed_multiplayer += card.drones_build_time_speed_multiplayer

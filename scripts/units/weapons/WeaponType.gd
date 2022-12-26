extends Resource
class_name WeaponType

export var reload:float = 150 # How fast Weapon shoot
export var shoot_spacing:float = 10 # TODO: Spacing when shooting
export var shots:int = 1 # Count of bullets \  
export var bullet_per_shot:int = 1 # Count of bullet if shoot_all_at_once is false 
export var rotation_speed:float = 3 # Rotation speed to Target
export var shoot_cone:float = 15 # Spread degrees of bullets
export var shoot_all_at_once:bool = true # Shoot all bullets at once
export var can_rotate:bool = true # Weapon rotating without unit
export var energy_per_shoot:float = 2.5
export(String, FILE, "*.tscn") var bullet:String # Reference to Bullet scene
export var texture:Texture # Texture (Optional)
export(Array, AudioStream) var shoot_sounds # Call when Weapon shooting

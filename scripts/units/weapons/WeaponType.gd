extends Resource
class_name WeaponType

export var reload:float = 150
export var shoot_spacing:float = 10
export var shots:int = 1
export var bullet_per_shot:int = 1
export var rotation_speed:float = 3
export var shoot_cone:float = 15
export var one_shot:bool = true
export(String, FILE, "*.tscn") var bullet:String
export var texture:Texture

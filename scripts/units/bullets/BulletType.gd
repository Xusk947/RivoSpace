extends Resource
class_name BulletType

export var damage:float = 10
export var lifetime:float = 100
export var speed:float = 1
export(String, FILE, "*.tscn") var hit_fx:String
export var texture:Texture

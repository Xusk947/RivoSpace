extends Resource
class_name BulletType

export var damage:float = 10 # Damage of bullet
export var lifetime:float = 50 # How much Bullet still alive
export var speed:float = 1 # Bullet speed
export(String, FILE, "*.tscn") var hit_fx:String # When bullet hit something, create hit_fx
# TODO: Move Texture to Bullet
export var texture:Texture # Bullet Texture

extends Node

var variables:Dictionary = {}
var to_print:Array = []

func _ready():
	to_print.append("bullets")

func set(key:String, value):
	variables[key] = value

func get(key:String):
	if variables.has(key):
		return variables[key]
	variables[key] = 0
	return 0

func _process(delta):
	for variable in to_print:
		if variables.has(variable):
			print(variables.get(variable))

extends Node

const EASY = "EASY"
const NORMAL = "NORMAL"
const HARD = "HARD"

var current_difficult = "EASY"

func get_difficult(diff:String):
	return _level[diff]

const _level:Dictionary = {
	"EASY": {
		distance = 3000
	},
	"NORMAL": {
		distance = 2500
	},
	"HARD": {
		distance = 4000
	}
}

# Distance - value used in Path Creation, says distance between start | Between (-1, 1) * [difficult].distance

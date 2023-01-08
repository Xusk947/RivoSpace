extends Node

static func select_random(arr:Array):
	randomize()
	return arr[int(rand_range(0, len(arr)))]

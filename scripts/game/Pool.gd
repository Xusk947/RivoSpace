extends Node

var min_load_amount:int = 20
var object_pool:Dictionary = {}

var _return_queue : Array = []

func _process(_delta):
	_clean_return_queue()

func take_node(path: String):
	var object
	if not path in object_pool:
		load_object(path)
	
	object = object_pool[path][0]
	object_pool[path].erase(object)
	
	if (len(object_pool[path]) < 1):
# warning-ignore:return_value_discarded
		object_pool.erase(path)
	object.set_process(true)
	object.set_physics_process(true)
	object.visible = true
	return object

func return_node(object):
	if (object is Node2D):
		object.visible = false
		object.set_process(false)
		object.set_physics_process(false)
		object.request_ready()
	if _return_queue.has(object):
		return
	_return_queue.append(object)

func load_object(path:String, load_amount:int = min_load_amount):
	var res = load(path)
	for _i in load_amount:
		var object = res.instance()
		if path in object_pool:
			object_pool[path].append(object)
		else:
			object_pool[path] = [object]

func _clean_return_queue():
	while len(_return_queue) != 0:
		var object = _return_queue.pop_front()
		if object == null:
			return
		var par = object.get_parent();
		if par == null:
			return
		par.remove_child(object)
		if object.filename in object_pool:
			object_pool[object.filename].append(object)
		else:
			object_pool[object.filename] = [object]

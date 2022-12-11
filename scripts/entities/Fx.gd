extends CPUParticles2D
class_name Fx

func _ready():
	restart()
	emitting = true
	if get_child_count() > 0:
		for child in get_children():
			if child is CPUParticles2D:
				child.emitting = true
	
func _process(_delta):
	if one_shot && !emitting:
		remove()

func set_color(color:Color):
	self.color = color
	if get_child_count() > 0:
		for child in get_children():
			if child is CPUParticles2D:
				pass
				child.color = color

func remove():
	emitting = false
	if get_child_count() > 0:
		for child in get_children():
			if child is CPUParticles2D:
				child.emitting = false
	Pool.return_node(self)
	
func add(node:Node2D = GameManager.scene_holder):
	if node:
		node.add_child(self)

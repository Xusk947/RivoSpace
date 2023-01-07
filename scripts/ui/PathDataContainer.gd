extends Container

var path_data:PathData setget _set_path_data, _get_path_data

func _ready():
	self.path_data = GameManager.path_data
	print(path_data.start_point)
	self.connect("resized", self, "_on_resize")

func _on_resize():
	_clear_children()
	_create_children_from_path()

func _set_path_data(v):
	_clear_children()
	path_data = v
	_create_children_from_path()
# Remove All children
func _clear_children():
	for child in get_children():
		Pool.return_node(child)
# Transform Path Data to Display
func _create_children_from_path():
	for path in path_data.path_points:
		var point:TextureButton = Pool.take_node(Res.path_point)
		var tex_size:Vector2 = point.texture_normal.get_size()
		point.name = "PathPoint"
		point.rect_position = Vector2((path.pos.x / 2 + 0.5) * rect_size.x - tex_size.x / 2, (path.pos.y / 2 + 0.5) * rect_size.y - tex_size.y / 2)
		for con in path.connections:
			var line = Line2D.new()
			line.width = 2
			line.add_point(Vector2((path.pos.x / 2 + 0.5) * rect_size.x, (path.pos.y / 2 + 0.5) * rect_size.y))
			line.add_point(Vector2((con.pos.x / 2 + 0.5) * rect_size.x, (con.pos.y / 2 + 0.5) * rect_size.y))
			add_child(line)
		add_child(point)

func _get_path_data():
	return path_data

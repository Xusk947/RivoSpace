extends ColorRect
class_name ColorFiller

var need_hide:bool = false

func _process(delta):
	if (need_hide):
		modulate.a = lerp(modulate.a, -0.1, 0.01);
	else:
		modulate.a = lerp(modulate.a, 1.1, 0.01);

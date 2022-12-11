extends Node
const pi = 3.1415927
const PI2 = 6.28319
const radd2deg = 180 / PI
const degg2rad = PI / 180

static func forward_distance(angle1:float, angle2:float) -> float:
	return Mathf.abs(angle1 - angle2)

static func backward_distance(angle1:float, angle2:float) -> float:
	return PI2 - Mathf.abs(angle1 - angle2)

static func angle_dist(a:float, b:float) -> float:
	a = Mathf.mod(a, PI2)
	b = Mathf.mod(b, PI2)
	if (a - b < 0):
		a = a - b + PI2
		if (b - a < 0):
			b = b - a + PI2
		else:
			b = b - a + PI2
	else:
		a = a - b
		if (b - a < 0):
			b = b - a + PI2
		else:
			b = b - a + PI2
	
	return Mathf.min(a, b)

static func move_toward(angle1:float, to1:float, speed:float) -> float:
	if(abs(angle_dist(angle1, to1)) < speed): return to1
	var angle = Mathf.mod(angle1, PI2)
	var to = Mathf.mod(to1, PI2)
	if(angle > to == (backward_distance(angle, to) > forward_distance(angle, to))):
		angle -= speed;
	else:
		angle += speed;
	return angle

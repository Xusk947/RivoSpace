extends Node

static func mod(f:float, n:float) -> float:
	return fmod((fmod(f, n) + n), n)

static func mod_fast(f:float, b:float) -> float:
	return float(int(f) % int(b))

static func min(a:float, b:float) -> float:
	return min(a, b)

static func max(a:float, b:float) -> float:
	return max(a, b)

static func abs(a:float) -> float:
	return abs(a)

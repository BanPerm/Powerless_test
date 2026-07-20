class_name Direction
extends RefCounted

enum Value { NORTH, EAST, SOUTH, WEST }

const VECTOR := {
	Value.NORTH: Vector2i(0, -1),
	Value.EAST: Vector2i(1, 0),
	Value.SOUTH: Vector2i(0, 1),
	Value.WEST: Vector2i(-1, 0),
}

const OPPOSITE := {
	Value.NORTH: Value.SOUTH,
	Value.SOUTH: Value.NORTH,
	Value.EAST: Value.WEST,
	Value.WEST: Value.EAST,
}

static func all() -> Array:
	return [Value.NORTH, Value.EAST, Value.SOUTH, Value.WEST]

static func rotate(direction: Value, degrees: int) -> Value:
	var steps: int = int(degrees / 90) % 4
	var current := direction
	for i in range(steps):
		match current:
			Value.NORTH: current = Value.EAST
			Value.EAST: current = Value.SOUTH
			Value.SOUTH: current = Value.WEST
			Value.WEST: current = Value.NORTH
	return current

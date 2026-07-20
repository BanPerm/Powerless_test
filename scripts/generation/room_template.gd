class_name RoomTemplate
extends Resource

enum Category { NORMAL, REST, BOSS, START }

@export var scene: PackedScene
@export var category: Category = Category.NORMAL
@export var weight: float = 1.0
@export var footprint: Vector2 = Vector2(10, 10)  # taille en orientation de base
@export var allow_rotation: bool = true

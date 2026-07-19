class_name RoomTemplate
extends Resource

@export var scene: PackedScene
@export var size_category: String = "medium"  # "small", "medium", "large" — pour varier la génération
@export var connection_points: Array[String] = ["north", "south"]  # les sockets que CETTE salle propose
@export var has_verticality: bool = false  # true si la salle contient des plateformes/dénivelé

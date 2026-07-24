extends CanvasLayer

var label: Label

func _ready() -> void:
	label = Label.new()
	label.add_theme_font_size_override("font_size", 14)
	label.position = Vector2(10, 10)
	add_child(label)

func _process(_delta: float) -> void:
	var fps = Engine.get_frames_per_second()
	var static_mem = OS.get_static_memory_usage() / 1024.0 / 1024.0
	var objects = Performance.get_monitor(Performance.OBJECT_COUNT)
	var nodes = Performance.get_monitor(Performance.OBJECT_NODE_COUNT)
	var draw_calls = Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
	var physics_time = Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0

	label.text = "FPS: %d\nMem: %.1f MB\nObjects: %d\nNodes: %d\nDraw calls: %d\nPhysics: %.2f ms" % [
		fps, static_mem, objects, nodes, draw_calls, physics_time
	]

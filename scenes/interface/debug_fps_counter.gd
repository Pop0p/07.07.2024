extends Label

func _process(delta: float) -> void:
	text = "%s ip/s" % str(Engine.get_frames_per_second())

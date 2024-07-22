extends ProgressBar


@export var engine_current_speed : FloatValue

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	engine_current_speed.float_value_changed.connect(_on_speed_changed)
	engine_current_speed.max_value_changed.connect(_on_max_speed_changed)
	engine_current_speed.min_value_changed.connect(_on_min_speed_cyanged)

func _on_speed_changed(new_value : float) -> void:
	value = new_value
		
func _on_max_speed_changed(new_value : float) -> void:
	max_value = new_value

func _on_min_speed_cyanged(new_value : float) -> void:
	min_value = new_value

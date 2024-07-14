class_name FloatValue extends Resource

@export var minimum_value : float
@export var maximum_value : float
@export var starting_value : float

var current_value : float : set = set_value, get = get_value
signal float_value_changed
signal max_value_changed
signal min_value_changed

func reset():
	current_value = starting_value

func set_value(new_value : float) -> void:
	current_value = max(0, min(maximum_value, new_value))
	float_value_changed.emit(current_value)
	
func get_value():
	return current_value
	
func set_max_value(new_value : float) -> void:
	maximum_value = new_value
	max_value_changed.emit(maximum_value)

func set_min_value(new_value : float) -> void:
	minimum_value = new_value
	min_value_changed.emit(minimum_value)

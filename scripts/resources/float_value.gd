class_name FloatValue extends Resource

@export var maximum_value : float
@export var starting_value : float

var current_value : float : set = set_value, get = get_value
signal float_value_changed

func reset():
	current_value = starting_value

func set_value(new_value : float):
	current_value = max(0, min(maximum_value, new_value))
	float_value_changed.emit(current_value)
	
func get_value():
	return current_value

extends Control

var _label := ""

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func with_data(label : String):
	_label = label
	return self


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

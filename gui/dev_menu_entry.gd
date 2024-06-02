extends Control

@onready var label_node := $Label as Label
@onready var spinbox_node := $SpinBox as SpinBox
var _label = ""
var _singleton_node

# Called when the node enters the scene tree for the first time.
func _ready():
	label_node.text = _label
	spinbox_node.set_value_no_signal(_singleton_node.val[_label])
	#spinbox_node.get_line_edit().text = str(EngineTweakable.val[_label])

func with_data(label : String, ypos : float, node):
	position.y = ypos
	_label = label
	_singleton_node = node
	return self


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_spin_box_value_changed(value):
	_singleton_node.val[_label] = value
	#print("new value for ", _label, " is ", value)

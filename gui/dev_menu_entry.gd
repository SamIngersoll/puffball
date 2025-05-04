extends Control

@export var entry_x_padding := 300 as float
@onready var label_node := $Label as Label
#@onready var spinbox_node := $SpinBox as SpinBox
@onready var node
var _label = ""
var _singleton_node

# Called when the node enters the scene tree for the first time.
func _ready():
	
	
	label_node.text = _label
	var value = _singleton_node.val[_label]
	if typeof(value) == TYPE_FLOAT or typeof(value) == TYPE_INT:
		node = SpinBox.new()
		node.set_value_no_signal(_singleton_node.val[_label])
		node.set_begin(Vector2(entry_x_padding, 0))
		add_child(node)
		node.value_changed.connect(_on_spin_box_value_changed)
	elif typeof(value) == TYPE_BOOL:
		node = CheckBox.new()
		node.set_pressed_no_signal(value)
		node.set_begin(Vector2(entry_x_padding, 0))
		node.toggle_mode = true
		add_child(node)
		var split = _label.rsplit(" / ", false, 1)
		var node_name = split[0]
		var param_name = split[1]
		var children = get_tree().get_nodes_in_group("levels")[0].get_children()
		for child in children:
			if child.name == node_name:
				#print(child)
				if child.name == "player":
					# this doesnt work but it should
					#node.toggled.connect(Callable(child, "set").bindv([param_name]))
					# so instead we need to do this
					node.toggled.connect(_on_check_box_toggled.bind(param_name, child))
			
			
				#child.set(param_name, value)
	elif typeof(value) == TYPE_STRING:
		node = LineEdit.new()
		node.insert_text_at_caret(value)
		node.set_begin(Vector2(entry_x_padding, 0))
		add_child(node)
	
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


func _on_check_box_toggled(toggled_on: bool, param_name:String, child:Node3D) -> void:
	#print("CALLING SELF")
	#print(param_name, toggled_on, child)
	child.set(param_name, toggled_on)

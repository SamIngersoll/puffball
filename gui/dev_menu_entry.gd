extends Control

@export var entry_x_padding := 500 as float
@onready var label_node := $Label as Label
#@onready var spinbox_node := $SpinBox as SpinBox
@onready var node
var _label = ""
var _singleton_node

func find_node_by_path(root: Node, path_parts: Array) -> Node:
	var current = root
	for name in path_parts:
		current = current.get_node_or_null(name)
		if current == null:
			return null
	return current
	
## Called when the node enters the scene tree for the first time.
func _ready():
	# Full label example: "Player / Timer / duration"
	var path_parts = _label.rsplit("/", false)
	#var path_parts = _label.split(" / ")
	if path_parts.size() < 2:
		push_error("Invalid label format: " + _label)
		return
	#print(_label)
	var param_name = path_parts[-1]  # Last part is the property name
	var node_path_parts = path_parts.slice(0, path_parts.size() - 1)

	var level_root = get_tree().get_nodes_in_group("levels")[0]
	var target_node = find_node_by_path(level_root, node_path_parts)
	if target_node == null:
		push_error("Could not find node at path: " + _label)
		return

	label_node.text = _label
	var value = _singleton_node.val[_label]

	if typeof(value) == TYPE_FLOAT or typeof(value) == TYPE_INT:
		node = SpinBox.new()
		if typeof(value) == TYPE_FLOAT:
			node.step = 0.05
		node.set_value_no_signal(value)
		node.set_begin(Vector2(entry_x_padding, 0))
		add_child(node)
		node.value_changed.connect(_on_spin_box_value_changed.bind(param_name, target_node))

	elif typeof(value) == TYPE_BOOL:
		node = CheckBox.new()
		node.set_pressed_no_signal(value)
		node.set_begin(Vector2(entry_x_padding, 0))
		node.toggle_mode = true
		add_child(node)
		node.toggled.connect(_on_check_box_toggled.bind(param_name, target_node))
	elif typeof(value) == TYPE_STRING:
		node = LineEdit.new()
		node.insert_text_at_caret(value)
		node.set_begin(Vector2(entry_x_padding, 0))
		add_child(node)


func with_data(label : String, ypos : float, node):
	position.y = ypos
	_label = label
	_singleton_node = node
	return self


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_spin_box_value_changed(value, param_name:String, child:Node3D):
	_singleton_node.val[_label] = value
	child.set(param_name, value)
	#print("new value for ", _label, " is ", value)


func _on_check_box_toggled(toggled_on: bool, param_name:String, child:Node3D) -> void:
	#print("CALLING SELF")
	#print(param_name, toggled_on, child)
	_singleton_node.val[_label] = toggled_on
	child.set(param_name, toggled_on)

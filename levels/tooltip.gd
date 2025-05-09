extends Node3D

@onready var label : Label3D = $Label3D
@onready var area : Area3D = $Area3D
## text for the label
@export var label_text : String = "your tip here" :
	set(val):
		# absolute pain in the ass finding this, otherwise the setter was 
		# called before the label node was instantiated 
		# https://forum.godotengine.org/t/best-practices-for-onready-and-export-setters/56461
		if not is_node_ready():
			await ready
		label.set_text(val)

# Called when the node enters the scene tree for the first time.
func _ready():
	area.area_entered.connect(_on_area_2d_body_entered)
	area.area_exited.connect(_on_area_2d_body_exited)
	print(label_text)
	label.set_text(label_text)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_area_2d_body_entered(body):
	print("player entered area")
	label.show()

func _on_area_2d_body_exited(body):
	print("player exited area")
	label.hide()

func HaveChildOfType(asType) -> Array:
	var ChildrenOfType = get_children().map(func(child): return is_instance_of(child, asType))
	if ChildrenOfType.is_empty():
		return []
	print(ChildrenOfType[0])
	#var child = ChildrenOfType[0]
	return ChildrenOfType
	

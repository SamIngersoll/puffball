extends Node3D

@export var text : String = "your tip here"
@export var label : Label3D
@export var area : Area3D

# Called when the node enters the scene tree for the first time.
func _ready():
	area.area_entered.connect(_on_area_2d_body_entered)
	area.area_exited.connect(_on_area_2d_body_exited)
	label.text = text

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

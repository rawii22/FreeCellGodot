extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	hide()


func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and !event.pressed and !get_parent().block_ui_changes:
		get_parent().hide_all_ui()
		hide()

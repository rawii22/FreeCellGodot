extends Area2D


var value
var suit
var color
var card_name

var is_being_dragged
var parent_column

var offset


# Called when the node enters the scene tree for the first time.
func _ready():
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_being_dragged:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			position = get_viewport().get_mouse_position() - offset # TODO: create loop here to position each card in the stack
		else:
			is_being_dragged = false
			get_parent().remove_child(self)
			parent_column.add_card(self)


func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			parent_column = get_parent()
			parent_column.remove_card(self) # TODO: use value returned from this call
			offset = event.position - (parent_column.position + position)
			reparent(get_parent().get_parent())
			is_being_dragged = true


func on_click():
	parent_column = get_parent()
	parent_column.remove_card(self)
	offset = get_viewport().get_mouse_position() - (parent_column.position + position)
	reparent(get_parent().get_parent())
	is_being_dragged = true

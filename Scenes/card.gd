extends Area2D

var card_spacing

var value
var suit
var color
var card_name

var is_being_dragged = false
var parent_column
var offset
var dragged_stack

var column_position

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	card_spacing = get_tree().get_root().get_node("Main/Table").card_spacing


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_being_dragged:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			for i in range(dragged_stack.size()):
				dragged_stack[i].position = get_viewport().get_mouse_position() - offset
				dragged_stack[i].position.y += (card_spacing * i)
		else:
			is_being_dragged = false
			for card in dragged_stack:
				card.get_parent().remove_child(card)
				parent_column.add_card(card)
			get_tree().get_root().get_node("Main/Table").toggle_action_happening()


func on_click():
	if !get_tree().get_root().get_node("Main/Table").is_action_happening():
		get_tree().get_root().get_node("Main/Table").toggle_action_happening()
		parent_column = get_parent()
		dragged_stack = parent_column.remove_card(self)
		offset = get_viewport().get_mouse_position() - (parent_column.position + position)
		for card in dragged_stack:
			card.reparent(get_parent().get_parent())
		is_being_dragged = true

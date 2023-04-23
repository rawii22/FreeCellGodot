extends Area2D

var card_spacing

var value
var suit
var color
var card_name

var is_being_dragged = false
var parent_area
var offset
var dragged_stack
var detected_area = null

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
			$DragArea.set_deferred("disabled", true)
			$CardArea.set_deferred("disabled", false)
			place_stack()
			get_tree().get_root().get_node("Main/Table").toggle_action_happening()


func on_click():
	if !get_tree().get_root().get_node("Main/Table").is_action_happening():
		get_tree().get_root().get_node("Main/Table").toggle_action_happening()
		parent_area = get_parent()
		if can_drag_stack(parent_area.get_card_stack(self)):
			$CardArea.set_deferred("disabled", true)
			$DragArea.set_deferred("disabled", false)
			dragged_stack = parent_area.remove_card(self)
			offset = get_viewport().get_mouse_position() - (parent_area.position + position)
			for card in dragged_stack:
				card.reparent(get_parent().get_parent())
			is_being_dragged = true
		else:
			get_tree().get_root().get_node("Main/Table").toggle_action_happening()
			#TODO: Fail to click animation here


#This checks if a stack of cards can be dragged by the player.
func can_drag_stack(stack):
	var can_move = true
	if stack.size() == 1 and !stack.front().get_parent().name.contains("Foundation"):
		return can_move
	
	for i in range(0, stack.size() - 1):
		if stack[i].color != stack[i+1].color: #opposite color
			if stack[i].value == stack[i+1].value + 1: #decreasing in value
				continue
		can_move = false
	return can_move


#This will place the card(s) in a new spot, or default to the original spot if the new spot is invalid.
func place_stack():
	for card in dragged_stack:
		card.get_parent().remove_child(card)
		
	if detected_area != null and detected_area.can_place_card(dragged_stack):
		detected_area.add_card(dragged_stack)
	else:
		parent_area.add_card(dragged_stack)


func _on_area_entered(area):
	if area.name.contains("Column") or area.name.contains("FreeCell") or area.name.contains("Foundation"):
		detected_area = area


func _on_area_exited(area):
	if is_being_dragged and (area.name.contains("Column") or area.name.contains("FreeCell") or area.name.contains("Foundation")):
		detected_area = null

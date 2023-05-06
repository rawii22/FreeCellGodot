extends Area2D

var card_spacing
var table

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
	table = get_tree().get_root().get_node("Main/Table")
	card_spacing = table.card_spacing


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
			make_move(detected_area)
			table.toggle_action_happening()


func _on_area_entered(area):
	if area.name.contains("Column") or area.name.contains("FreeCell") or area.name.contains("Foundation"):
		detected_area = area


func _on_area_exited(area):
	if is_being_dragged and (area.name.contains("Column") or area.name.contains("FreeCell") or area.name.contains("Foundation")):
		detected_area = null


func on_click(is_auto = false):
	if !table.is_action_happening():
		table.toggle_action_happening() #First block other things from happening
		parent_area = get_parent()	#Remember the parent in case the card does not move
		if can_drag_stack(parent_area.get_card_stack(self)): #Is the card/stack moveable?
			$CardArea.set_deferred("disabled", true)
			$DragArea.set_deferred("disabled", false)
			dragged_stack = parent_area.remove_card(self)
			offset = get_viewport().get_mouse_position() - (parent_area.position + position)
			for card in dragged_stack:
				card.reparent(get_parent().get_parent())
			if is_auto:
				if !auto_click():
					for card in dragged_stack:
						card.get_node("ShakeAnimation").play("shake")
					return false
					pass
				else:
					return true
			else:
				is_being_dragged = true
		else:
			table.toggle_action_happening()
			for card in parent_area.get_card_stack(self):
				card.get_node("ShakeAnimation").play("shake")


func auto_click():
	var move_occured = false
	for i in range(4):
		if !move_occured:
			detected_area = get_tree().get_root().get_node("Main/Table/Foundation" + str(i + 1))
			if detected_area.can_place_card(dragged_stack):
				move_occured = true
	
	for i in range(8): #Auto move card to a column that already has cards on it
		if !move_occured:
			detected_area = get_tree().get_root().get_node("Main/Table/Column" + str(i + 1))
			if detected_area != parent_area:
				if detected_area.can_place_card(dragged_stack) and !detected_area.is_empty():
					move_occured = true
	
	for i in range(8): #If no occupied column was found, then look for an empty one
		if !move_occured:
			detected_area = get_tree().get_root().get_node("Main/Table/Column" + str(i + 1))
			if detected_area != parent_area:
				if detected_area.can_place_card(dragged_stack):
					move_occured = true

	for i in range(4):
		if !move_occured:
			detected_area = get_tree().get_root().get_node("Main/Table/FreeCell" + str(i + 1))
			if detected_area.can_place_card(dragged_stack):
				move_occured = true
	
	make_move(detected_area)
	
	$DragArea.set_deferred("disabled", true)
	$CardArea.set_deferred("disabled", false)
	table.toggle_action_happening()
	
	if detected_area == parent_area:
		return false
	else:
		return move_occured


#This checks if a stack of cards can be dragged by the player.
func can_drag_stack(stack):
	#This check might not be needed since the card's click area is disabled once it enters the foundation.
	if stack.size() == 1:
		return !stack.front().get_parent().name.contains("Foundation") #Prevent cards from being moved out of the foundation
	
	var can_move = true
	for i in range(0, stack.size() - 1):
		if stack[i].color != stack[i+1].color: #opposite color
			if stack[i].value == stack[i+1].value + 1: #decreasing in value
				continue
		can_move = false
	if stack.size() > table.max_stack_size:
		can_move = false
	return can_move


#This function mainly exists to keep track of moves
func make_move(destination, check_move = true):
	if !check_move: #An assumption is being made here that the only time check_move will be false is when a move is being undone.
		parent_area = get_parent()
		dragged_stack = parent_area.remove_card(self)
	
	for card in dragged_stack:
		card.get_parent().remove_child(card)
	
	if !check_move:
		destination.add_card(dragged_stack)
	elif destination != null and destination.can_place_card(dragged_stack):
		var add_move = true
		if parent_area.name.contains("FreeCell"):
			if destination.name.contains("FreeCell"):
				add_move = false
			if destination.name.contains("Column"):
				if destination.is_empty():
					add_move = false
		elif parent_area.name.contains("Column") and parent_area.is_empty():
			if destination.name.contains("FreeCell"):
				add_move = false
		destination.add_card(dragged_stack)
		var move = table.Move.new()
		move.card = self
		move.first_position = parent_area
		move.second_position = destination
		
		if add_move:
			table.move_made(move)
	else:
		parent_area.add_card(dragged_stack)

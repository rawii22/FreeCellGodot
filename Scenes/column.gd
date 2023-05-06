extends Area2D

var cards = []

var card_spacing
var table

# Called when the node enters the scene tree for the first time.
func _ready():
	table = get_tree().get_root().get_node("Main/Table")
	card_spacing = table.card_spacing


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


#This is function makes it easier in other places when you don't know if your card is a single or a stack.
#It prevents me from having to write for-loops everywhere
func add_card(data, do_animation = true):
	if cards.size() == 0:
		table.update_free_cells(-1, true)
	match typeof(data):
		TYPE_ARRAY:
			add_cards(data, do_animation)
		TYPE_OBJECT:
			add_card_single(data, do_animation)


# This function is expecting the specified card to have no parent before use
func add_card_single(card, do_animation):
	add_child(card)
	
	#This code can animate single cards moving from once column to another column. It breaks for some stacks and other scenarios.
#	if do_animation:
#		card.position = Vector2((int(str(card.parent_area.name).right(1))-int(str(self.name).right(1)))*262, card_spacing * card.column_position)
#		var tween = get_tree().create_tween()
#		tween.tween_property(card, "position", Vector2(0, cards.size() * card_spacing), 0.3)
#		tween.play()
#	else:

	card.position = Vector2(0, cards.size() * card_spacing)
	card.column_position = cards.size()
	
	cards.append(card)


func add_cards(cards, do_animation):
	for card in cards:
		add_card_single(card, do_animation)


#Returns an array, in order from the clicked card to the topmost card, holding the stack of cards that was just grabbed
func remove_card(card):
	var stack = []
	var original_card_count = cards.size()
	for i in range(card.column_position, cards.size()): #each card's column_position value is not updated while being dragged since it will never be used
		stack.append(cards.pop_back())
	stack.reverse()
	
	#If all the cards are being removed
	if stack.size() == original_card_count:
		table.update_free_cells(1, true)
	
	return stack


func get_card_stack(card):
	var stack = []
	for i in range(card.column_position, cards.size()): #each card's column_position value is not updated while being dragged since it will never be used
		stack.append(cards[i])
	return stack


func can_place_card(stack):
	if cards.size() == 0 and stack.size() > table.max_stack_size / 2:
		return false
	
	if cards.size() == 0:
		return true
		
	if cards.back().color != stack.front().color:
		if cards.back().value == stack.front().value + 1:
			return true
	return false


func is_empty():
	return cards.size() == 0

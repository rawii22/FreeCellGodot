extends Area2D

var cards = []

var card_spacing

# Called when the node enters the scene tree for the first time.
func _ready():
	card_spacing = get_tree().get_root().get_node("Main/Table").card_spacing


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


#This is function makes it easier in other places when you don't know if your card is a single or a stack.
#It prevents me from having to write for-loops everywhere
func add_card(data):
	match typeof(data):
		TYPE_ARRAY:
			add_cards(data)
		TYPE_OBJECT:
			add_card_single(data)


# This function is expecting the specified card to have no parent before use
func add_card_single(card):
	add_child(card)
	card.column_position = cards.size()
	card.position = Vector2(0, cards.size() * card_spacing)
	cards.append(card)


func add_cards(cards):
	for card in cards:
		add_card_single(card)


#Returns an array, in order from the clicked card to the topmost card, holding the stack of cards that was just grabbed
func remove_card(card):
	var stack = []
	for i in range(card.column_position, cards.size()): #each card's column_position value is not updated while being dragged since it will never be used
		stack.append(cards.pop_back())
	stack.reverse()
	return stack


func get_card_stack(card):
	var stack = []
	for i in range(card.column_position, cards.size()): #each card's column_position value is not updated while being dragged since it will never be used
		stack.append(cards[i])
	return stack


func can_place_card(stack):
	if cards.back().color != stack.front().color:
		if cards.back().value == stack.front().value + 1:
			return true
	return false

extends Area2D

var cards = []

var card_spacing

# Called when the node enters the scene tree for the first time.
func _ready():
	card_spacing = get_tree().get_root().get_node("Main/Table").card_spacing


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# This function is expecting the specified card to have no parent before use
func add_card(card):
	add_child(card)
	card.column_position = cards.size()
	card.position = Vector2(0, cards.size() * card_spacing)
	card.column_position = cards.size()
	cards.append(card)


#Returns an array, in order from the clicked card to the topmost card, holding the stack of cards that was just grabbed
func remove_card(card):
	var stack = []
	for i in range(card.column_position, cards.size()): #each card's column_position value is not updated while being dragged since it will never be used
		stack.append(cards.pop_back())
	stack.reverse()
	return stack

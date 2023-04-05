extends Area2D

var cards = []


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# This function is expecting the specified card to have no parent before use
func add_card(card):
	add_child(card)
	cards.append(card)
	card.position = Vector2(0, (cards.size() - 1) * 92)


func remove_card(card):
	var card_index = cards.find(card)
	var stack = []
	for i in range(card_index, cards.size()):
		stack.append(cards.pop_back())
	return stack

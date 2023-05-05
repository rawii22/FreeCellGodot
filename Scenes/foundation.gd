extends Area2D

var cards = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func add_card(card_list):
	var card = card_list.front()
	card.get_node("CardArea").set_deferred("disabled", true)
	add_child(card)
	card.position = Vector2(0, 0)
	card.column_position = cards.size()
	cards.append(card)


func remove_card(card):
	card.get_node("CardArea").set_deferred("disabled", false)


#Cards are not allowed to be moved from this area. It is the card's responsibility to make sure it
#does not move if it in the foundation. This is here to allow the checks in "card" to stay generic.
func get_card_stack(card):
	var card_array = []
	card_array.push_back(card)
	return card_array;


func can_place_card(stack):
	if typeof(stack) == TYPE_OBJECT:
		var stack_array = []
		stack_array.push_back(stack)
		stack = stack_array
	
	if stack.size() > 1:
		return false
	
	if cards.size() == 0:
		if stack.front().value == 1:
			return true
		else:
			return false
	
	if cards.back().suit == stack.front().suit:
		if cards.back().value == stack.front().value - 1:
			return true
	
	return false

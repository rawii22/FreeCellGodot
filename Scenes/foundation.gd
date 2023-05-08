extends Area2D

var cards = []
var is_full = false


func add_card(card_list):
	var card = card_list.front()
	card.get_node("CardArea").set_deferred("disabled", true)
	add_child(card)
	card.position = Vector2(0, 0)
	card.column_position = cards.size()
	cards.append(card)
	if card.value == 13:
		is_full = true


func remove_card(card):
	card.get_node("CardArea").set_deferred("disabled", false)
	var stack = []
	stack.push_back(cards.pop_back())
	if card.value == 13:
		is_full = false
	return stack


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

extends Area2D

var has_card = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func add_card(card_list):
	var card = card_list.front()
	has_card = true
	add_child(card)
	card.position = Vector2(0, 0)


#Cards here must be returned as an array to allow cards.gd to run generically on "stacks" of cards
func remove_card(card):
	has_card = false
	var card_array = []
	card_array.push_back(card)
	return card_array;


func get_card_stack(card):
	var card_array = []
	card_array.push_back(card)
	return card_array;


func can_place_card(stack):
	if stack.size() > 1:
		return false
	return !has_card

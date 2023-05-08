extends Area2D

var has_card = false
var held_card = null
var table

# Called when the node enters the scene tree for the first time.
func _ready():
	table = get_tree().get_root().get_node("Main/Table")


func add_card(card_list):
	var card = card_list.front()
	has_card = true
	add_child(card)
	held_card = card
	card.position = Vector2(0, 0)
	card.column_position = 1
	table.update_free_cells(-1)


#Cards here must be returned as an array to allow cards.gd to run generically on "stacks" of cards
func remove_card(card):
	held_card = null
	has_card = false
	var card_array = []
	card_array.push_back(card)
	table.update_free_cells(1)
	return card_array;


#since this area cannot hold "stacks" it simply returns the card it's holding as a "stack"
func get_card_stack(card):
	var card_array = []
	card_array.push_back(card)
	return card_array;


func can_place_card(stack):
	if stack.size() > 1:
		return false
	return !has_card

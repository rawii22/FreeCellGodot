extends Node2D

@export var card_scene: PackedScene

var movement_occuring = false
var card_spacing = 92

class Move:
	var card
	var first_position
	var second_position


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


#TODO: On right click outside of a card, auto move all cards that can be moved to the foundation to the foundation

#This is supposed to be like an auto-move for cards that can go to the foundation. It only moves one card at a time.
func _on_table_area_input_event(viewport, event, shape_idx):
	if !movement_occuring and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		var current_area
		var current_card
		var move_occured = false
		
		for i in range(8):
			if !move_occured:
				current_area = get_tree().get_root().get_node("Main/Table/Column" + str(i + 1))
				if current_area.cards.size() > 0:
					current_card = current_area.cards.back()
					if can_go_in_foundation(current_card):
						move_occured = current_card.on_click(true)
		
		for i in range(4):
			if !move_occured:
				current_area = get_tree().get_root().get_node("Main/Table/FreeCell" + str(i + 1))
				if current_area.has_card:
					current_card = current_area.held_card
					if can_go_in_foundation(current_card):
						move_occured = current_card.on_click(true)


func can_go_in_foundation(card):
	var current_foundation
	for j in range(4):
		current_foundation = get_tree().get_root().get_node("Main/Table/Foundation" + str(j + 1))
		if current_foundation.can_place_card(card):
			return true


func clear_board():
	for i in range(8):
		get_node("Column" + str(i + 1)).cards.clear()
		
	for i in range(4):
		get_node("FreeCell" + str(i + 1)).has_card = false
		get_node("Foundation" + str(i + 1)).cards.clear()
		
	get_tree().call_group("card", "queue_free")
	


func deal_cards():
	var cards = []
	
	for i in range(52):
		var card = card_scene.instantiate()
		
		match i / 13:
			0:
				card.suit = "spade"
				card.color = "black"
			1:
				card.suit = "club"
				card.color = "black"
			2:
				card.suit = "diamond"
				card.color = "red"
			3:
				card.suit = "heart"
				card.color = "red"
		
		card.value = (i % 13) + 1
		card.card_name = str(card.value) + "_" + card.suit
		
		card.get_node("Sprite2D").texture = load("res://Assets/Cards/" + card.card_name + ".png")
		
		cards.append(card)
	
	cards.shuffle()
	
	var card_to_deal
	
	#TODO: Dealing animation?
	
	for i in range(8):
		for j in range(6):
			card_to_deal = cards.pop_front()
			get_node("Column" + str(i + 1)).add_card(card_to_deal)
			card_to_deal.show()
	
	for i in range(4):
		card_to_deal = cards.pop_front()
		get_node("Column" + str(i + 1)).add_card(card_to_deal)
		card_to_deal.show()


func toggle_action_happening():
	movement_occuring = !movement_occuring


func is_action_happening():
	return movement_occuring

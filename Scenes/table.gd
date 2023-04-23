extends Node2D

@export var card_scene: PackedScene

var movement_occuring = false #TODO: fix this in all other classes that need to touch this
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

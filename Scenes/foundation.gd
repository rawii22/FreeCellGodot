extends Area2D

var num_cards = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func add_card(card):
	add_child(card)
	card.position = Vector2(0, 0)
	num_cards += 1


func remove_card(card):
	num_cards -= 1

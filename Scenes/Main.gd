extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	new_game()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _input(event):
	if event.is_action_pressed("New Game"):
		new_game()


func new_game():
	#TODO: if they have made at least one move, ask if they are sure they want to lose progress on the game?
	$Table.clear_board()
	$Table.deal_cards()

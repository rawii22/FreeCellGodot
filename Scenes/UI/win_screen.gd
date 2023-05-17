extends Control

var table

func _ready():
	hide()
	table = get_tree().get_root().get_node("Main/Table")


func construct(complete_time, new_best_time, moves_made, new_best_moves, is_custom):
	var history_string = ""
	for move in table.move_history:
		match move.card.value:
			10:
				history_string += "T"
			11:
				history_string += "J"
			12:
				history_string += "Q"
			13:
				history_string += "K"
			1:
				history_string += "A"
			_:
				history_string += str(move.card.value)
		history_string += move.card.suit.left(1).to_upper() + "->"
		history_string += move.second_position.name + "\n"
	
	$MoveHistory/HistoryText.text = history_string
	
	$CompleteTime.text = "%d:%02d" % [floor(complete_time / 60), int(complete_time) % 60]
	$Moves.text = str(moves_made)
	
	if is_custom:
		$CustomGameMessage.show()
		return
	
	$BestTimeLabel.show()
	$BestTime.text = "%d:%02d" % [floor(table.best_time / 60), int(table.best_time) % 60]
	if new_best_time:
		$BestTime.text += "*"
		$StarIndicator.show()
	$BestTime.show()
	
	$BestMovesLabel.show()
	$BestMoves.text = str(table.best_moves)
	if new_best_moves:
		$StarIndicator.show()
		$BestMoves.text += "*"
	$BestMoves.show()
	
	$WinRateLabel.show()
	$WinRate.text = "%.2f" % ((float(table.games_won) / table.games_played) * 100) + "%"
	$WinRate.show()


func _on_new_game_pressed():
	get_tree().get_root().get_node("Main/Table").new_game()


func _on_new_numbered_game_pressed():
	get_tree().get_root().get_node("Main/Table").new_game(false, randi() % 10000000)


func _on_replay_pressed():
	get_tree().get_root().get_node("Main/Table").replay()


func _on_history_button_pressed():
	$MoveHistory.visible = !$MoveHistory.visible

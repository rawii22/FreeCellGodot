extends Control

var table

func _ready():
	hide()
	table = get_tree().get_root().get_node("Main/Table")


func construct(complete_time, new_best_time, moves_made, new_best_moves, is_custom):
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

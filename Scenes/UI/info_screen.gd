extends Control

var table

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	table = get_tree().get_root().get_node("Main/Table")


func _on_exit_button_pressed():
	hide()


func _input(event):
	if event.is_action_pressed("Info"):
		visible = !visible


func _on_visibility_changed():
	if get_parent() != null:
		if visible:
			get_parent().ui_changed(1)
			get_parent().get_node("SettingsMenu").lose_focus()
			update_info()
		else:
			get_parent().ui_changed(-1)
			if get_parent().get_node("SettingsMenu").visible:
				get_parent().get_node("SettingsMenu/Resume").grab_focus()


func _on_reset_stats_pressed():
	#TODO:
	#Create confirm object
	#If confirm,
	table.reset_stats()
	update_info()


func update_info():
	$StatsBackground/GamesPlayed.text = str(table.current_stats.games_played)
	$StatsBackground/GamesWon.text = str(table.current_stats.games_won)
	if table.current_stats.games_played > 0:
		$StatsBackground/WinRate.text = "%.2f" % ((float(table.current_stats.games_won) / table.current_stats.games_played) * 100) + "%"
		$StatsBackground/BestTime.text = "%d:%02d" % [floor(table.current_stats.best_time / 60), int(table.current_stats.best_time) % 60]
		$StatsBackground/BestMoves.text = str(table.current_stats.best_moves)
	else:
		$StatsBackground/WinRate.text = ""
		$StatsBackground/BestTime.text = ""
		$StatsBackground/BestMoves.text = ""

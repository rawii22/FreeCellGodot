extends Control

@export var confirm_screen_scene: PackedScene

var table
var GUI

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	table = get_tree().get_root().get_node("Main/Table")
	GUI = get_tree().get_root().get_node("Main/GUI")


func _on_exit_button_pressed():
	if !GUI.block_ui_changes:
		hide()


func _input(event):
	if event.is_action_pressed("Info") and !GUI.block_ui_changes:
		visible = !visible


func _on_visibility_changed():
	if get_parent() != null:
		if visible:
			get_parent().ui_changed(1)
			get_parent().get_node("SettingsMenu").lose_focus()
			update_info()
		else:
			get_parent().ui_changed(-1)
			if get_parent().open_ui == 1 and get_parent().get_node("SettingsMenu").visible:
				get_parent().get_node("SettingsMenu/Resume").grab_focus()


func _on_reset_stats_pressed():
	if !GUI.block_ui_changes:
		var confirmation_screen = confirm_screen_scene.instantiate()
		get_parent().add_child(confirmation_screen)
		if await confirmation_screen.confirm("are you sure you want to reset stats?", false):
			table.reset_stats()
			update_info()
		confirmation_screen.queue_free()


func update_info():
	$StatsBackground/GamesPlayed.text = str(table.games_played)
	$StatsBackground/GamesWon.text = str(table.games_won)
	if table.games_played > 0:
		$StatsBackground/WinRate.text = "%.2f" % ((float(table.games_won) / table.games_played) * 100) + "%"
		$StatsBackground/BestTime.text = "%d:%02d" % [floor(table.best_time / 60), int(table.best_time) % 60]
		$StatsBackground/BestMoves.text = str(table.best_moves)
	else:
		$StatsBackground/WinRate.text = ""
		$StatsBackground/BestTime.text = ""
		$StatsBackground/BestMoves.text = ""

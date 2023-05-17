extends Control

signal response_made

var table
var GUI
var response = null

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	table = get_tree().get_root().get_node("Main/Table")
	GUI = get_tree().get_root().get_node("Main/GUI")


func confirm(prompt, focus_confirm = null, confirm_text = "yes", reject_text = "no"):
	GUI.block_ui(true)
	$Menu/Prompt.text = prompt
	$Menu/Confirm/Label.text = confirm_text
	$Menu/Reject/Label.text = reject_text
	
	if focus_confirm != null:
		if focus_confirm:
			$Menu/Confirm.grab_focus()
		else:
			$Menu/Reject.grab_focus()
	show()
	
	await self.response_made
	hide()
	if get_tree().get_nodes_in_group("confirmation").size() == 1 and !table.auto_completing:
		GUI.block_ui(false)
	return response


func _on_reject_pressed():
	response = false
	response_made.emit()


func _on_confirm_pressed():
	response = true
	response_made.emit()


func _input(event):
	if event.is_action_pressed("Settings"):
		response = false
		response_made.emit()

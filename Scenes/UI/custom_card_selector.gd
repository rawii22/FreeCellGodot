extends Control

#The reason this is not a toggle button is because I need finer control over what happens.
# Is the button pressed via the user? Or via the code? I need to be able to do different things
# for both of those scenarios in order to prevent the code from cycling over and over agian.

var card_id
var value
var resting_alpha = 0.8
var hover_alpha = 1
var disabled_alpha = 0.5
var pressed = false

var unpressed_texture
var pressed_texture

#Again, since this is not a toggle button, the textures must be handled manually.
func _ready():
	var value_str = self.name.substr(self.name.length()-2) #First check if value is two digits
	if value_str.is_valid_int():
		value = int(value_str)
	else:
		value = int(self.name.substr(self.name.length()-1))#Else, value must be 1 digit
	card_id = value - 1
	value = (card_id % 13) + 1
	unpressed_texture = load("res://Assets/Values/" + str(value) + ".png")
	pressed_texture = load("res://Assets/Values/" + str(value) + "_selected.png")
	$ValueButton.set_texture_normal(unpressed_texture)
	self.modulate.a = resting_alpha


func _on_value_button_mouse_entered():
	if !$ValueButton.disabled:
		self.modulate.a = 1


func _on_value_button_mouse_exited():
	if !$ValueButton.disabled:
		self.modulate.a = resting_alpha


func _on_value_button_focus_entered():
	_on_value_button_mouse_entered()


func _on_value_button_focus_exited():
	_on_value_button_mouse_exited()


#If the button is pressed, put the card into the selected area. If the button is not pressed, it will
# simply pass the card ID and be done. If the button is currently pressed, replace the existing card
# in the selected area with the card value, but if the card in the selected area is the same as the
# card ID then user is trying to toggle the card so remove the card and be done.
func _on_value_button_button_down():
	if pressed:
		unpress()
		var removed_card_position = get_tree().get_root().get_node("Main/GUI/CustomGameScreen").remove_card(card_id)
		if (removed_card_position + 1) == get_tree().get_root().get_node("Main/GUI/CustomGameScreen").selected_area.area_id:
			return
	
	if !pressed:
		press()
		get_tree().get_root().get_node("Main/GUI/CustomGameScreen").add_card(card_id)


func press():
	pressed = true
	$ValueButton.set_texture_normal(pressed_texture)


func unpress():
	pressed = false
	$ValueButton.set_texture_normal(unpressed_texture)


func enable():
	self.modulate.a = resting_alpha
	$ValueButton.disabled = false


func disable():
	unpress()
	self.modulate.a = disabled_alpha
	$ValueButton.disabled = true

extends Control

var area_id

#This is terrbile. Since the card areas are not being generated through code, the values must be ripped from the name.
func _ready():
	var value_str = self.name.substr(self.name.length()-2) #First check if value is two digits
	if value_str.is_valid_int():
		area_id = int(value_str)
	else:
		area_id = int(self.name.substr(self.name.length()-1))#Else, value must be 1 digit


func _on_texture_button_mouse_entered():
	$HoverOutline.show()


func _on_texture_button_mouse_exited():
	$HoverOutline.hide()


func _on_texture_button_focus_entered():
	_on_texture_button_button_down()


func _on_texture_button_button_down():
	get_tree().get_root().get_node("Main/GUI/CustomGameScreen").select_area(self)


#If the area is right-clicked, remove the card.
func _on_texture_button_gui_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		get_tree().get_root().get_node("Main/GUI/CustomGameScreen").clear_card_area(area_id)


func focus():
	_on_texture_button_button_down()
	$TextureButton.grab_focus()


func select():
	$Outline.show()


func unselect():
	$Outline.hide()


func set_texture(texture):
	$TextureButton.texture_normal = texture

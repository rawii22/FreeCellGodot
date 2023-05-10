extends Control

var value

#This is terrbile. Since the card areas are not being generated through code, the values must be ripped from the name.
func _ready():
	var value_str = self.name.substr(self.name.length()-2) #First check if value is two digits
	if value_str.is_valid_int():
		value = int(value_str)
	else:
		value = int(self.name.substr(self.name.length()-1))#Else, value must be 1 digit
	value -= 1


func _on_texture_button_mouse_entered():
	$HoverOutline.show()


func _on_texture_button_mouse_exited():
	$HoverOutline.hide()


func _on_texture_button_button_down():
	get_tree().get_root().get_node("Main/GUI/CustomGameScreen").select_area(self)


func unselect():
	$Outline.hide()


func select():
	$Outline.show()


func set_texture(texture):
	$TextureButton.texture_normal = texture

extends TextureButton

# Called when the node enters the scene tree for the first time.
func _ready():
	self.pressed.connect(self._button_pressed)


#If anything is open, close it. Otherwise, open the settings menu.
func _button_pressed():
	get_parent().get_node("SettingsMenu").toggle()


func _input(event):
	if event.is_action_pressed("Settings"):
		_button_pressed()

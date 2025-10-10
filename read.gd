extends Control



@onready var filename = Global.filename
@onready var filepath = "user://notes/%s.json" % Global.filename
var text: Dictionary
@onready var changer = $Changer
@onready var bg2col = $Background2.get_theme_color("panel")
var fontsize
@onready var screen: Vector2 = DisplayServer.window_get_size()
var showchanger: bool = false
@onready var old_height = $TextEdit.size
@onready var textedit = $TextEdit
@onready var kb_height = DisplayServer.virtual_keyboard_get_height()
var is_setting_open: bool = false







func _ready() -> void:
	print($Background2.modulate)
	
	
	# Init
	get_viewport().connect("size_changed", Callable(self, "_on_screen_resized"))
	textedit.connect("focus_entered", Callable(self, "textedit_focus_entered"))
	self.connect("", Callable(self, "textedit_focus_exited"))
	#/Init
	
	#
	#print(bg2col)
	#bg2col = Vector4(0.0, 0.0, 0.0, 0.0)
	#print(bg2col)
	#
	
	
	#Initially move the changer to right of the screen hidden
	changer.position.x = ((screen.x / 2) - changer.size.x / 2) + screen.x 
	changer.position.y = (screen.y / 2) - changer.size.y / 2
	
	$SettingContainer.position.x = ((screen.x / 2) - $SettingContainer.size.x / 2)
	$SettingContainer.position.y = (screen.y / 2) - $SettingContainer.size.y / 2  + screen.y
	
	
	#fontsize = $TextEdit.get_theme_font_size("font_size")
	#print(fontsize)
	$TextEdit.add_theme_font_size_override("font_size", 32) 
	
	
	
	readcontents(filepath)


func savecontents(path: String, data: String) -> void:
	var newdata = {"title": filename, "content": data}
	save_json(filepath, newdata)
	pass


func readcontents(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("Failed to open JSON file: " + path)
	var json_text = JSON.parse_string(file.get_as_text()) 
	
	$TextEdit.text = json_text["content"]


func save_json(file_path: String, data: Dictionary) -> void:
	var json_text = JSON.stringify(data, "\t")  
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		push_error("Failed to open file for writing: " + file_path)

	# Write JSON text and close
	file.store_string(json_text)
	file.close()
 

func textedit_focus_entered():
	print("focused")
	await get_tree().create_timer(0.2).timeout
	var keyb_height = DisplayServer.virtual_keyboard_get_height()
	#var keyb_height = 500
	print(keyb_height)
	if keyb_height > 0:
		var tween = create_tween()
		tween.tween_property(textedit, "size", Vector2(old_height.x, textedit.size.y - keyb_height - 100), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		await tween.finished
		tween.kill()
	#textedit.size.y = textedit.size.y - keyb_height - 100


func textedit_focus_exited():
	print("unfocused")
	textedit.size.y = old_height.y


func _on_save_pressed() -> void:
	savecontents(filepath, $TextEdit.text)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")


func _on_item_list_item_selected(index: int) -> void:
	print(index)


func _on_screen_resized():
	#MOve the changer to right of the screen
	changer.position.x = ((screen.x / 2) - changer.size.x / 2) + screen.x 
	changer.position.y = (screen.y / 2) - changer.size.y / 2
	
	#Move the setting container at top


func _on_changer_mouse_exited() -> void:
	if InputEventScreenTouch:
		pass


func _on_properties_pressed() -> void:
	if !is_setting_open:
		$Background2.show()
		var tween = create_tween()
		var tween2 = create_tween()
		tween.tween_property($SettingContainer, "position", Vector2(screen.x / 2 - $SettingContainer.size.x / 2, (screen.y /2 - $SettingContainer.size.y / 2)), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween2.tween_property($Background2, "self_modulate", Vector4(1.0, 1.0, 1.0, 1.0), 0.2)
		
		

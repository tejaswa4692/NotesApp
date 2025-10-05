extends Control

@onready var filename = Global.filename
@onready var filepath = "user://notes/%s.json" % Global.filename
var text: Dictionary
@onready var changer = $Changer
@onready var bg2col = $Background2.get_theme_color("panel")
var fontsize
@onready var screen: Vector2 = DisplayServer.window_get_size()
var showchanger: bool = false


func _ready() -> void:
	get_viewport().connect("size_changed", Callable(self, "_on_viewport_resized"))
	_on_viewport_resized()
	
	
	
	
	print(bg2col)
	bg2col = Vector4(0.0, 0.0, 0.0, 0.0)
	print(bg2col)
	
	
	changer.position.x = ((screen.x / 2) - changer.size.x / 2) + screen.x 
	changer.position.y = (screen.y / 2) - changer.size.y / 2
	
	
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
 

func _on_save_pressed() -> void:
	savecontents(filepath, $TextEdit.text)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")


func _on_item_list_item_selected(index: int) -> void:
	print(index)

func _on_viewport_resized():
	# Get the height of the virtual keyboard
	var keyboard_height = DisplayServer.virtual_keyboard_get_height()

	# If the keyboard is visible, adjust the Control node's height
	if keyboard_height > 0:
		size.y =- keyboard_height





func _on_changer_mouse_exited() -> void:
	if InputEventScreenTouch:
		pass

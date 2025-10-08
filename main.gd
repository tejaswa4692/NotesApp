extends  Control

var notes_folder = "user://notes/"
@onready var panel = $Panel
@onready var screen: Vector2 = DisplayServer.window_get_size()
var is_newscreenopen: bool = false
@onready var line = $Panel/LineEdit
var messages = [
	"Baby name toh dalo",
	 "kya kar rahi ho",
	 "bhondu name dalo",
	 "NAME?!?!?!?",
	 "slowpoke ho kya",
	"baby name dalte ha",
	"Tejas jaisi ho kya ap"
	]
var _last_number: int = -1 


func _ready():
	$ColorRect.set_instance_shader_parameter("Bar Width", 0.1)
	get_viewport().connect("size_changed", Callable(self, "_on_screen_resized"))
	panel.show()
	panel.position.x = screen.x / 2 - panel.size.x / 2
	panel.position.y = (screen.y - panel.size.y / 2) + screen.y / 2
	# Open the user:// folder first
	
	
	var base_dir = DirAccess.open("user://")
	
	
	if base_dir and not base_dir.dir_exists("notes"):
		# Create the notes folder
		base_dir.make_dir("notes")
	populate_itemlist()

func _on_screen_resized():
	screen = DisplayServer.window_get_size()

func populate_itemlist():
	var dir = DirAccess.open(notes_folder)
	if dir == null:
		return
	$ItemList.clear()
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".json"):
			$ItemList.add_item(file_name.substr(0, file_name.length() - 5))
		file_name = dir.get_next()
	dir.list_dir_end()
	
func create_note_file(title: String, content: String) -> void:
	var note_data = {
		"title": title,
		"content": content,
	}
	# Construct full path
	var file_path = "user://notes/%s.json" % title
	# Save JSON to file
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(note_data))
		file.close()
	else:
		push_error("Failed to create note file: " + file_path)
	populate_itemlist()


func _on_button_pressed() -> void:
	if !is_newscreenopen:
		line.text = ""
		line.placeholder_text = "Enter file name"
		var tween = create_tween()
		tween.tween_property(panel, "position", Vector2(screen.x / 2 - panel.size.x / 2, screen.y /2 - panel.size.y / 2), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		await tween.finished
		tween.kill()
		is_newscreenopen = true



func _on_button_2_pressed() -> void:
	if is_newscreenopen:
		var tween = create_tween()
		tween.tween_property(panel, "position", Vector2(screen.x / 2 - panel.size.x / 2, (screen.y /2 - panel.size.y / 2) + screen.y * 2), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		is_newscreenopen = false


func _on_item_list_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	Global.filename = $ItemList.get_item_text(index)
	get_tree().change_scene_to_file("res://read.tscn")


func _on_create_pressed() -> void:
	if line.text != "":
		create_note_file(line.text, "")
		if is_newscreenopen:
			var tween = create_tween()
			tween.tween_property(panel, "position", Vector2(screen.x / 2 - panel.size.x / 2, (screen.y /2 - panel.size.y / 2) + screen.y *2), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			is_newscreenopen = false
	else:
		line.placeholder_text = messages[rand_no_repeat(0, len(messages) - 1)]



func rand_no_repeat(min_val: int, max_val: int) -> int:
	var n = randi() % (max_val - min_val + 1) + min_val
	if max_val - min_val > 0:
		while n == _last_number:
			n = randi() % (max_val - min_val + 1) + min_val
	_last_number = n
	return n

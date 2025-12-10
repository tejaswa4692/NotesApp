extends Control

var notes_folder = "user://notes/"
@onready var panel = $Panel
@onready var delpanel = $Delete
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
const baseres: Vector2 = Vector2(1920, 1080)

var indextodelete: int = 0

# Touch detection variables
var touch_start_pos = Vector2()
var is_scrolling = false
var is_scrolling_delete = false
var scroll_threshold = 20

func _ready():
	resize_everything()
	
	$ColorRect.set_instance_shader_parameter("Bar Width", 0.1)
	get_viewport().connect("size_changed", Callable(self, "_on_screen_resized"))
	panel.show()
	panel.position.x = screen.x / 2 - panel.size.x / 2
	panel.position.y = (screen.y - panel.size.y / 2) + screen.y / 2
	delpanel.position.x = screen.x / 2 - panel.size.x / 2
	delpanel.position.y = (screen.y - panel.size.y / 2) + screen.y / 2
	
	var base_dir = DirAccess.open("user://")
	
	if base_dir and not base_dir.dir_exists("notes"):
		base_dir.make_dir("notes")
	
	# Connect manual input handling
	$ItemList.gui_input.connect(_on_item_list_input)
	$Delete/DeleteList.gui_input.connect(_on_delete_list_input)
	
	populate_itemlist()

func _on_screen_resized():
	screen = DisplayServer.window_get_size()
	resize_everything()

func resize_everything():
	var scale_factor_vec = screen / baseres
	var scale_factor = ((scale_factor_vec.x/2) + scale_factor_vec.y) * 0.5
	$RichTextLabel.add_theme_font_size_override("normal_font_size", (150 * scale_factor))
	$RichTextLabel2.add_theme_font_size_override("normal_font_size", (45 * scale_factor))
	$Panel/RichTextLabel.add_theme_font_size_override("normal_font_size", (60 * scale_factor))
	$Panel/LineEdit.add_theme_font_size_override("font_size", (66 * scale_factor))
	$Panel/Create.add_theme_font_size_override("font_size", (41 * scale_factor))
	$Panel/Button2.add_theme_font_size_override("font_size", (36 * scale_factor))
	$Delete/RichTextLabel.add_theme_font_size_override("normal_font_size", (60 * scale_factor))
	$Delete/DelButton.add_theme_font_size_override("font_size", (41 * scale_factor))
	$Panel/Button2.add_theme_font_size_override("font_size", (36 * scale_factor))
	$Delete/Confirm_Delete/RichTextLabel.add_theme_font_size_override("normal_font_size", (60 * scale_factor))
	$Delete/Confirm_Delete/ConfirmDelete.add_theme_font_size_override("font_size", (41 * scale_factor))
	$Delete/Confirm_Delete/GoBack.add_theme_font_size_override("font_size", (30 * scale_factor))
	$Delete/Confirm_Delete/Name_Of_File.add_theme_font_size_override("font_size", (60 * scale_factor))

func populate_itemlist():
	var dir = DirAccess.open(notes_folder)
	if dir == null:
		return
	$ItemList.clear()
	$Delete/DeleteList.clear()
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".json"):
			$ItemList.add_item(file_name.substr(0, file_name.length() - 5))
			$Delete/DeleteList.add_item(file_name.substr(0, file_name.length() - 5))
		file_name = dir.get_next()
	dir.list_dir_end()

func create_note_file(title: String, content: String) -> void:
	var note_data = {
		"title": title,
		"content": content,
		"fontsize" : 50,
		"fontcolor": [0.57, 0.32, 0.31, 1.00],
		"panelcolor": [0.80, 0.64, 0.65, 1.00]
	}
	var file_path = "user://notes/%s.json" % title
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(note_data))
		file.close()
	else:
		push_error("Failed to create note file: " + file_path)
	populate_itemlist()

# Handle ItemList touch input
func _on_item_list_input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_start_pos = event.position
			is_scrolling = false
		else:
			if not is_scrolling:
				var item_at_pos = $ItemList.get_item_at_position(event.position)
				if item_at_pos != -1:
					Global.filename = $ItemList.get_item_text(item_at_pos)
					get_tree().change_scene_to_file("res://read.tscn")
	
	elif event is InputEventScreenDrag:
		if touch_start_pos.distance_to(event.position) > scroll_threshold:
			is_scrolling = true

# Handle DeleteList touch input
func _on_delete_list_input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_start_pos = event.position
			is_scrolling_delete = false
		else:
			if not is_scrolling_delete:
				var item_at_pos = $Delete/DeleteList.get_item_at_position(event.position)
				if item_at_pos != -1:
					print($Delete/DeleteList.get_item_text(item_at_pos))
					$Delete/Confirm_Delete.show()
					$Delete/Confirm_Delete/Name_Of_File.text = $Delete/DeleteList.get_item_text(item_at_pos)
					indextodelete = item_at_pos
	
	elif event is InputEventScreenDrag:
		if touch_start_pos.distance_to(event.position) > scroll_threshold:
			is_scrolling_delete = true

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

func _on_create_pressed() -> void:
	var file_path = "user://notes/%s.json" % line.text
	if FileAccess.file_exists(file_path):
		line.placeholder_text = "Filename exist"
		line.text = ""
	else:
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

func _on_delete_menu_opener_pressed() -> void:
	if !is_newscreenopen:
		var tween = create_tween()
		tween.tween_property(delpanel, "position", Vector2(screen.x / 2 - delpanel.size.x / 2, screen.y /2 - delpanel.size.y / 2), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		await tween.finished
		tween.kill()
		is_newscreenopen = true

func _on_delete_menu_close_pressed() -> void:
	if is_newscreenopen:
		var tween = create_tween()
		tween.tween_property(delpanel, "position", Vector2(screen.x / 2 - delpanel.size.x / 2, (screen.y /2 - delpanel.size.y / 2) + screen.y * 2), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		is_newscreenopen = false

func _on_confirm_delete_pressed() -> void:
	var file_path = "user://notes/%s.json" % $Delete/Confirm_Delete/Name_Of_File.text
	
	$ItemList.remove_item(indextodelete)
	$Delete/DeleteList.remove_item(indextodelete)
	
	if FileAccess.file_exists(file_path):
		var err = DirAccess.remove_absolute(file_path)
	else:
		printerr("File not exist Error")
	$Delete/Confirm_Delete.hide()
	
	if is_newscreenopen:
		var tween = create_tween()
		tween.tween_property(delpanel, "position", Vector2(screen.x / 2 - delpanel.size.x / 2, (screen.y /2 - delpanel.size.y / 2) + screen.y * 2), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		is_newscreenopen = false

func _on_go_back_pressed() -> void:
	$Delete/Confirm_Delete.hide()

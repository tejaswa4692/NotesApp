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
var is_scrolled_up: bool = false
var propertymenu: bool = false
const baseres: Vector2 = Vector2(1920, 1080)
var fontcolor
@onready var paneltheme = preload("res://texteditpanelcolor.tres")  # or load() if dynamic
var panelcolor = Color(0.808, 0.647, 0.651, 1.0)



func _ready() -> void:
	
	
	# Init
	$Changer/FontSizeProperty.hide()
	$Changer/FontColorProperty.hide()
	$Changer/BackgroundSelector.hide()
	$Background3.hide()
	$Background2.hide()
	get_viewport().connect("size_changed", Callable(self, "_on_screen_resized"))
	textedit.connect("focus_entered", Callable(self, "textedit_focus_entered"))
	#self.connect("", Callable(self, "textedit_focus_exited"))
	
	
	var scale_factor_vec = screen / baseres
	var scale_factor = ((scale_factor_vec.x/2) + scale_factor_vec.y) * 0.5
	$Save.add_theme_font_size_override("font_size", (40 * scale_factor))
	$Back.add_theme_font_size_override("font_size", (40 * scale_factor))
	$Properties.add_theme_font_size_override("font_size", (40 * scale_factor))
	$Changer/BackgroundSelector/RichTextLabel.add_theme_font_size_override("font_size", (70 * scale_factor))
	#/Init
	
	
	#Initially move the changer to right of the screen hidden
	changer.position.x = ((screen.x / 2) - changer.size.x / 2) + screen.x 
	changer.position.y = (screen.y / 2) - changer.size.y / 2
	
	$SettingContainer.position.x = ((screen.x / 2) - $SettingContainer.size.x / 2)
	$SettingContainer.position.y = (screen.y / 2) - $SettingContainer.size.y / 2  + screen.y
	
	
	#fontsize = $TextEdit.get_theme_font_size("font_size")
	
	
	readcontents(filepath)


func savecontents(data: String) -> void:
	var newdata = {"title": filename, "content": data, "fontsize": fontsize, "fontcolor": [fontcolor.r, fontcolor.g, fontcolor.b, fontcolor.a], "panelcolor": [panelcolor.r, panelcolor.g, panelcolor.b, panelcolor.a]}
	save_json(filepath, newdata)
	pass


func readcontents(path: String) -> void:
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("Failed to open JSON file: " + path)
	var json_text = JSON.parse_string(file.get_as_text()) 
	
	
	$TextEdit.add_theme_font_size_override("font_size", json_text["fontsize"])
	$TextEdit.text = json_text["content"]
	$Changer/FontSizeProperty/fontsizeslider.value = json_text["fontsize"]
	fontcolor = Color(json_text["fontcolor"][0], json_text["fontcolor"][1], json_text["fontcolor"][2], json_text["fontcolor"][3])
	$TextEdit.add_theme_color_override("font_color", fontcolor)
	$Changer/FontColorProperty/Panel/ColorPickerButton.color = fontcolor
	panelcolor = Color(json_text["panelcolor"][0], json_text["panelcolor"][1], json_text["panelcolor"][2], json_text["panelcolor"][3])
	paneltheme.bg_color = panelcolor
	paneltheme.border_color = panelcolor


func save_json(file_path: String, data: Dictionary) -> void:
	var json_text = JSON.stringify(data, "\t")  
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		push_error("Failed to open file for writing: " + file_path)

	# Write JSON text and close
	file.store_string(json_text)
	file.close()
 

func textedit_focus_entered():
	is_scrolled_up = true
	await get_tree().create_timer(0.2).timeout
	var keyb_height = DisplayServer.virtual_keyboard_get_height()
	#var keyb_height = 500
	if keyb_height > 0:
		var tween = create_tween()
		tween.tween_property(textedit, "size", Vector2(old_height.x, textedit.size.y - keyb_height - 100), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		await tween.finished
		tween.kill()
	#textedit.size.y = textedit.size.y - keyb_height - 100


func textedit_focus_exited():
	textedit.size.y = old_height.y


func _on_save_pressed() -> void:
	savecontents($TextEdit.text)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")


func _on_screen_resized():
	screen = DisplayServer.window_get_size()
	var scale_factor_vec = screen / baseres
	var scale_factor = ((scale_factor_vec.x/2) + scale_factor_vec.y) * 0.5
	$Save.add_theme_font_size_override("font_size", (40 * scale_factor))
	$Back.add_theme_font_size_override("font_size", (40 * scale_factor))
	$Properties.add_theme_font_size_override("font_size", (40 * scale_factor))
	$Changer/BackgroundSelector/RichTextLabel.add_theme_font_size_override("font_size", (70 * scale_factor))
	
	
	#MOve the changer to right of the screen
	if !propertymenu:
		$SettingContainer.position.x = ((screen.x / 2) - $SettingContainer.size.x / 2) + screen.x 
		$SettingContainer.position.y = (screen.y / 2) - $SettingContainer.size.y / 2
		changer.position.x = ((screen.x / 2) - changer.size.x / 2) + screen.x 
		changer.position.y = (screen.y / 2) - changer.size.y / 2
	else:
		changer.position.x = ((screen.x / 2) - changer.size.x / 2)
		changer.position.y = (screen.y / 2) - changer.size.y / 2
		
		$SettingContainer.position.x = ((screen.x / 2) - $SettingContainer.size.x / 2)
		$SettingContainer.position.y = (screen.y / 2) - $SettingContainer.size.y / 2 
	#Move the setting container at top


func _on_changer_mouse_exited() -> void:
	if InputEventScreenTouch:
		pass

#this function opens the settings container 
func _on_properties_pressed() -> void:
	if !is_setting_open:
		$Background2.show()
		var tween = create_tween()
		$SettingContainer.show()
		tween.tween_property($SettingContainer, "position", Vector2(screen.x / 2 - $SettingContainer.size.x / 2, (screen.y /2 - $SettingContainer.size.y / 2)), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		is_setting_open = true


func _on_backgroundexitbutton_pressed() -> void:
	if is_setting_open and !propertymenu:
		var tween = create_tween()
		tween.tween_property($SettingContainer, "position", Vector2(((screen.x / 2) - $SettingContainer.size.x / 2), (screen.y / 2) - $SettingContainer.size.y / 2  + screen.y), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		#tween2.tween_property($Background2, "self_modulate", Vector4(0.0, 0.0, 0.0, 0.0), 0.2)
		await tween.finished
		$Background2.hide()
		is_setting_open = false


func _on_text_small_maker_pressed() -> void:
	if $TextEdit.focus_mode and is_scrolled_up:
		var tween = create_tween()
		tween.tween_property(textedit, "size", Vector2(old_height.x, old_height.y), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		is_scrolled_up = false

#This func is responsible for the property inner menu thats opened from the list of properties
func _on_item_list_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	propertymenu = true
	var tween = create_tween()
	$Background3.show()
	$Changer.show()
	var propertytochange = $SettingContainer/ItemList.get_item_text(index)
	tween.tween_property($Changer, "position", Vector2(screen.x / 2 - $Changer.size.x / 2, (screen.y /2 - $Changer.size.y / 2)), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	$Changer/RichTextLabel.text= propertytochange
	
	match propertytochange:
		"Font Size":
			$Changer/FontSizeProperty.show()
			$Changer/FontColorProperty.hide()
			$Changer/BackgroundSelector.hide()
			$Changer/PanelColor.hide()
		"Font Color":
			$Changer/FontSizeProperty.hide()
			$Changer/FontColorProperty.show()
			$Changer/BackgroundSelector.hide()
			$Changer/PanelColor.hide()
		"Background":
			$Changer/FontSizeProperty.hide()
			$Changer/FontColorProperty.hide()
			$Changer/BackgroundSelector.show()
			$Changer/PanelColor.hide()
		"Panel Color":
			$Changer/FontSizeProperty.hide()
			$Changer/FontColorProperty.hide()
			$Changer/BackgroundSelector.hide()
			$Changer/PanelColor.show()


func _on_propertyexitbutton_pressed() -> void:
	if propertymenu:
		var tween = create_tween()
		tween.tween_property($Changer, "position", Vector2(screen.x / 2 - $Changer.size.x / 2, (screen.y /2 - $Changer.size.y / 2) + screen.y + 150), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		await tween.finished
		$Background3.hide()
		propertymenu = false





#code responsible for hiding the ui elements when the slider is held
func _on_fontsizeslider_drag_started() -> void:
	fade_out_panel($Background3)
	fade_out_panel($SettingContainer)
	fade_out_panel($Background2)
	


#code responsible for showing the ui elements when the slider is unheld 
func _on_fontsizeslider_drag_ended(_value_changed: bool) -> void:
	fade_in_panel($Background3)
	fade_in_panel($SettingContainer)
	fade_in_panel($Background2)


#these 2 funcitions faded in and out the panels when the slider is grabbed (reusable)
func fade_out_panel(panel: Panel, duration: float = 0.2) -> void:
	panel.visible = true
	var tween = create_tween()
	tween.tween_property(panel, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	panel.hide()

func fade_in_panel(panel: Panel, duration: float = 0.2) -> void:
	panel.show()
	var tween = create_tween()
	tween.tween_property(panel, "modulate:a", 1.0, duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)


func _on_fontsizeslider_value_changed(value: float) -> void:
	$TextEdit.add_theme_font_size_override("font_size", value)
	fontsize = value


func _on_color_picker_button_color_changed(color: Color) -> void:
	$TextEdit.add_theme_color_override("font_color", color)
	fontcolor = color

func _on_color_picker_button_picker_created() -> void:
	fade_out_panel($Background3)
	fade_out_panel($SettingContainer)
	fade_out_panel($Background2)


func _on_color_picker_button_popup_closed() -> void:
	fade_in_panel($Background3)
	fade_in_panel($SettingContainer)
	fade_in_panel($Background2)


func _on_panelcolorpicker_picker_created() -> void:
	fade_out_panel($Background3)
	fade_out_panel($SettingContainer)
	fade_out_panel($Background2)


func _on_panelcolorpicker_popup_closed() -> void:
	fade_in_panel($Background3)
	fade_in_panel($SettingContainer)
	fade_in_panel($Background2)


func _on_panelcolorpicker_color_changed(color: Color) -> void:
	paneltheme.bg_color = color
	paneltheme.border_color = color
	panelcolor = color

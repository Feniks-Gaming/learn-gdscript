extends Node

const THEME_ROOT := "res://ui/theme/"
const THEME_FONTS_ROOT := "res://ui/theme/fonts/"

var _font_size_defaults := {}


func _ready() -> void:
	_cache_font_size_defaults()
	
	var current_profile := UserProfiles.get_profile()
	scale_all_font_sizes(current_profile.font_size_scale, false)


func _cache_font_size_defaults() -> void:
	_font_size_defaults.clear()
	
	var fs = Directory.new()
	var error = fs.change_dir(THEME_FONTS_ROOT)
	if error != OK:
		printerr("Failed to open theme fonts directory at '%s': Error code %d" % [THEME_FONTS_ROOT, error])
		return
	
	error = fs.list_dir_begin(true, true)
	if error != OK:
		printerr("Failed to read theme fonts directory at '%s': Error code %d" % [THEME_FONTS_ROOT, error])
		return
	
	var current_file := fs.get_next() as String
	while not current_file.empty():
		if current_file.get_extension() != "tres":
			current_file = fs.get_next()
			continue
		
		var font_resource = ResourceLoader.load(THEME_FONTS_ROOT.plus_file(current_file)) as DynamicFont
		if not font_resource:
			current_file = fs.get_next()
			continue
		
		_font_size_defaults[font_resource] = font_resource.size
		current_file = fs.get_next()


func scale_all_font_sizes(size_scale: int, and_save: bool = true) -> void:
	for font_resource in _font_size_defaults:
		font_resource = font_resource as DynamicFont
		if not font_resource:
			continue
		
		var default_size = int(_font_size_defaults[font_resource])
		# Each scale unit equals 2 points of font size.
		font_resource.size = default_size + size_scale * 2
	
	if and_save:
		var current_profile := UserProfiles.get_profile()
		current_profile.font_size_scale = size_scale
		current_profile.save()

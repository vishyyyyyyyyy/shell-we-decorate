extends Area2D

var selecting_color := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

signal shell_selected(shell_id: int)
signal color_selected(color: String)
signal stars_selected(count: int)
signal barnacle_selected(count: int)
signal bow_selected(enabled: bool)

var selected_shell := 0


func get_unlocked_colors():

	var colors = []

	if Global.upgrades["purple"]:
		colors.append("purple")

	if Global.upgrades["yellow"]:
		colors.append("yellow")

	if Global.upgrades["pink"]:
		colors.append("pink")

	return colors
#
func _input_event(_viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if selecting_color:
			var colors = get_unlocked_colors()
			var color_index = shape_idx - 3  # Color colliders start at index 3
			if color_index >= 0 and color_index < colors.size():
				emit_signal("color_selected", colors[color_index])
		else:
			# Shells
			if shape_idx >= 0 and shape_idx <= 2:
				#print(shape_idx)
				emit_signal("shell_selected", shape_idx)
				

			# Extras
			elif shape_idx == 6:  # barnacle
				#print(shape_idx)
				emit_signal("barnacle_selected", 1)

			elif shape_idx == 7:  # star
				#print(shape_idx)
				emit_signal("stars_selected", 1)   
				

			elif shape_idx == 8:  # bow
				#print(shape_idx)
				emit_signal("bow_selected", true)

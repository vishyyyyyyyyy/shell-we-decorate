extends Area2D

var selecting_color := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

signal shell_selected(shell_id: int)
signal color_selected(color: String)

var selected_shell := 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_unlocked_colors():

	var colors = []

	if Global.upgrades["purple"]:
		colors.append("purple")

	if Global.upgrades["yellow"]:
		colors.append("yellow")

	if Global.upgrades["pink"]:
		colors.append("pink")

	return colors

func _input_event(viewport, event, shape_idx):

	if event is InputEventMouseButton \
	and event.pressed \
	and event.button_index == MOUSE_BUTTON_LEFT:

		if selecting_color:
			var colors = get_unlocked_colors()
			var color_index = shape_idx - 3

			if color_index >= 0 and color_index < colors.size():
				emit_signal("color_selected", colors[color_index])

		else:
			if shape_idx >= 0 and shape_idx < 3:
				emit_signal("shell_selected", shape_idx)

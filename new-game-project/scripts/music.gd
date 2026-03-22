extends Area2D

@export var mute : Texture2D
@export var music : Texture2D

@onready var sprite: Sprite2D = $Sprite2D


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton \
	and event.pressed \
	and event.button_index == MOUSE_BUTTON_LEFT:
		get_tree().paused = !get_tree().paused
		if get_tree().paused:
			sprite.texture = mute
		else:
			sprite.texture = music

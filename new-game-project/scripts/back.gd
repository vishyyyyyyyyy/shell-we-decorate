extends Area2D
@onready var sprite: Sprite2D = $Button
@export var normal : Texture2D
@export var hover: Texture2D

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton \
	and event.pressed \
	and event.button_index == MOUSE_BUTTON_LEFT:
		get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_mouse_entered() -> void:
	sprite.texture = hover

func _on_mouse_exited() -> void:
	sprite.texture = normal

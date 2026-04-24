extends Area2D

@export var paused : Texture2D
@export var paused_hover: Texture2D
@export var normal : Texture2D
@export var normal_hover: Texture2D

@onready var sprite: Sprite2D = $Sprite2D


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton \
	and event.pressed \
	and event.button_index == MOUSE_BUTTON_LEFT:
		get_tree().paused = !get_tree().paused
		if get_tree().paused:
			sprite.texture = paused
		else:
			sprite.texture = normal


func _on_mouse_shape_entered(shape_idx: int) -> void:
	if sprite.texture == normal:
		sprite.texture = normal_hover
	if sprite.texture == paused:
		sprite.texture = paused_hover
		
		


func _on_mouse_exited() -> void:
	if sprite.texture == normal_hover:
		sprite.texture = normal
	if sprite.texture == paused_hover:
		sprite.texture = paused

extends Area2D

@export var normal : Texture2D
@export var hover: Texture2D

@onready var sprite: Sprite2D = $Sprite2D


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton \
	and event.pressed \
	and event.button_index == MOUSE_BUTTON_LEFT:
		get_tree().paused = !get_tree().paused
		$"../achievement".visible=true


func _on_mouse_shape_entered(shape_idx: int) -> void:
	if sprite.texture == normal:
		sprite.texture = hover
		
func _on_mouse_exited() -> void:
	if sprite.texture == hover:
		sprite.texture = normal

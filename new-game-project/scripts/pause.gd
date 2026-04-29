extends Area2D

@export var paused : Texture2D
@export var paused_hover: Texture2D
@export var normal : Texture2D
@export var normal_hover: Texture2D

@onready var sprite: Sprite2D = $Sprite2D


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton \
	and event.pressed \
	and event.button_index == MOUSE_BUTTON_LEFT:
		get_tree().paused = !get_tree().paused
		if get_tree().paused:
			$"../home/CollisionShape2D".set_deferred("disabled", false)
			$"../credits/CollisionShape2D".set_deferred("disabled", false)
			sprite.texture = paused
			$"../home".input_pickable = true
			$"../credits".input_pickable = true
			$"../ColorRect".visible=true
			$"../credits".visible=true
			$"../home".visible=true
		else:
			$"../home".set_deferred("input_pickable", true)
			$"../credits".set_deferred("input_pickable", true)
			sprite.texture = normal
			$"../home".input_pickable = false
			$"../credits".input_pickable = false
			$"../ColorRect".visible=false
			$"../credits".visible=false
			$"../home".visible=false

func _on_mouse_entered() -> void:
	if sprite.texture == normal:
		sprite.texture = normal_hover
	if sprite.texture == paused:
		sprite.texture = paused_hover
		
		


func _on_mouse_exited() -> void:
	if sprite.texture == normal_hover:
		sprite.texture = normal
	if sprite.texture == paused_hover:
		sprite.texture = paused

extends Area2D

@export var hover : Texture2D
@export var normal : Texture2D

@onready var sprite: Sprite2D = $Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.texture = normal


func _on_mouse_entered() -> void:
	sprite.texture = hover

func _on_mouse_exited() -> void:
	sprite.texture = normal

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton \
	and event.pressed \
	and event.button_index == MOUSE_BUTTON_LEFT:
		get_tree().change_scene_to_file("res://scenes/game.tscn")

extends Area2D

@export var hover : Texture2D
@export var normal : Texture2D

@onready var sprite: Sprite2D = $Button
signal start

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
		$".".visible=false
		$CollisionShape2D.disabled=true
		$"../label".visible=false
		$"../label2".visible=false
		$"../Infobox".visible=false
		$"../label".visible=false
		$"../label2".visible=false
		$"../label3".visible=false
		emit_signal("start")
		

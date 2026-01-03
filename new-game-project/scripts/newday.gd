extends Area2D

@export var hover : Texture2D
@export var normal : Texture2D

@onready var sprite: Sprite2D = $Button
signal newday

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
		$"../shop".visible=false
		$"../label2".visible=false
		$"../label".visible=false
		$"../label3".visible=false
		$CollisionShape2D.disabled=true
		$"../Infobox".visible=false
		$"../pearllabel".visible=false
		$"../Pearl".visible=false
		$"../../timerlabel".visible=true
		$"../panel".visible=false
		$"../panel2".visible=false
		$"../panel3".visible=false
		$"../panel4".visible=false
		$"../panel5".visible=false
		$"../panel6".visible=false
		emit_signal("newday")
		

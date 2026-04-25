extends Area2D

@export var normal : Texture2D
@export var hover: Texture2D

@onready var sprite: Sprite2D = $Sprite2D

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton \
	and event.pressed \
	and event.button_index == MOUSE_BUTTON_LEFT:
		get_tree().paused = !get_tree().paused
		$"../achievement/Area2D/CollisionShape2D".disabled=false
		$"../achievement".visible=true
		if Global.achievements["flawless_day"]["unlocked"] == true:
			$"../achievement/achievementtitle".text = Global.achievements["flawless_day"]["name"]
			$"../achievement/desc".text = Global.achievements["flawless_day"]["desc"]
			
		if Global.achievements["maxed_out"]["unlocked"] == true:
			$"../achievement/achievementtitle".text = Global.achievements["maxed_out"]["name"]
			$"../achievement/desc".text = Global.achievements["maxed_out"]["desc"]
		
		if Global.achievements["shell_legend"]["unlocked"] == true:
			$"../achievement/achievementtitle".text = Global.achievements["shell_legend"]["name"]
			$"../achievement/desc".text = Global.achievements["shell_legend"]["desc"]

		if Global.achievements["chaos_mode"]["unlocked"] == true:
			$"../achievement/achievementtitle".text = Global.achievements["chaos_mode"]["name"]
			$"../achievement/desc".text = Global.achievements["chaos_mode"]["desc"]
	
		


func _on_mouse_shape_entered(shape_idx: int) -> void:
	if sprite.texture == normal:
		sprite.texture = hover
		
func _on_mouse_exited() -> void:
	if sprite.texture == hover:
		sprite.texture = normal

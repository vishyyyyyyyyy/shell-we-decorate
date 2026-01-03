extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton \
	and event.pressed \
	and event.button_index == MOUSE_BUTTON_LEFT:
		if shape_idx == 0 and Global.pearls_earned >= 100:
			$"../panel/Label".text = "Sold Out"
			$CollisionShape2D.disabled=true
			$"../panel/Pearl".visible=false
			Global.pearls_earned -= 100
			$"../pearllabel".text = str(Global.pearls_earned)
			Global.upgrades["purple"] = true
			return
		if shape_idx == 1 and Global.pearls_earned >= 100:
			$"../panel2/Label".text = "Sold Out"
			$CollisionShape2D2.disabled=true
			$"../panel2/Pearl".visible=false
			Global.pearls_earned -= 100
			$"../pearllabel".text = str(Global.pearls_earned)
			Global.upgrades["yellow"] = true
			return
		if shape_idx == 2 and Global.pearls_earned >= 100:
			$"../panel3/Label".text = "Sold Out"
			$CollisionShape2D3.disabled=true
			$"../panel3/Pearl".visible=false
			Global.pearls_earned -= 100
			$"../pearllabel".text = str(Global.pearls_earned)
			Global.upgrades["pink"] = true
			return
		if shape_idx == 3 and Global.pearls_earned >= 200:
			$"../panel4/Label".text = "Sold Out"
			$CollisionShape2D4.disabled=true
			$"../panel4/Pearl".visible=false
			Global.pearls_earned -= 200
			$"../pearllabel".text = str(Global.pearls_earned)
			Global.upgrades["barnacle"] = true
			return
		if shape_idx == 4 and Global.pearls_earned >= 300:
			$"../panel5/Label".text = "Sold Out"
			$CollisionShape2D5.disabled=true
			$"../panel5/Pearl".visible=false
			Global.pearls_earned -= 300
			$"../pearllabel".text = str(Global.pearls_earned)
			Global.upgrades["starfish"] = true
			return
		if shape_idx == 5 and Global.pearls_earned >= 400:
			$"../panel6/Label".text = "Sold Out"
			$CollisionShape2D6.disabled=true
			$"../panel6/Pearl".visible=false
			Global.pearls_earned -= 400
			$"../pearllabel".text = str(Global.pearls_earned)
			Global.upgrades["bow"] = true
			return

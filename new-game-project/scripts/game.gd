extends Node2D

const DAY_LENGTH := 60
const HOURS := 24
const SECONDS_PER_HOUR := DAY_LENGTH / HOURS
var time_passed := 0.0
var current_hour := 0
var day_active := false
var order_failed := false

var selected_shell_id := 0

var selected_color = "none"

@onready var timerlabel = $timerlabel

@export var crab_textures: Array[Texture2D]
@onready var crab_sprite: Sprite2D = $Crab/Crab

@onready var face: Sprite2D = $orderrequest/face
@export var happy: Texture2D
@export var sad: Texture2D

@onready var shells := [
	$Crab/shell1,
	$Crab/shell2,
	$Crab/shell3
]

@onready var pearls = $pearls

var crab_present := false
var order_completed := true

var current_order = {
	"shape": "", 
	"color": "",
	"stars": -1,
	"bow": false,
	"barnacle": -1
}


@onready var purplepanel = $stand/customizepanel/panel/purple
@onready var yellowpanel = $stand/customizepanel/panel2/yellow
@onready var pinkpanel = $stand/customizepanel/panel3/pink

@onready var purple_shells = [$Crab/purple1, $Crab/purple2, $Crab/purple3]
@onready var yellow_shells = [$Crab/yellow1, $Crab/yellow2, $Crab/yellow3]
@onready var pink_shells = [$Crab/pink1, $Crab/pink2, $Crab/pink3]

func _ready() -> void:
	#purplepanel.visible = Global.upgrades["purple"]
	$info.visible=true
	$info/Area2D.visible=true
	$Crab/Crab.visible = false
	#end_day()
	$"end day/shop".shop.connect(shop)
	$"end day/newday".newday.connect(new_day)
	$info/Area2D.start.connect(start)
	$stand/customizepanel.shell_selected.connect(_on_shell_selected)
	$stand/customizepanel.color_selected.connect(_on_color_selected)


func _process(delta: float) -> void:
	if not day_active:
		return

	time_passed += delta

	var new_hour := int(time_passed / SECONDS_PER_HOUR)

	if new_hour != current_hour:
		current_hour = new_hour
		timerlabel.text = "%02d:00" % current_hour

	if current_hour >= 24 and day_active:
		end_day()


func start():
	$AnimationPlayer.play("fadeinday")
	await $AnimationPlayer.animation_finished
	day_active = true
	$stand/customizepanel/CollisionShape2D2.disabled=false
	$stand/customizepanel/CollisionShape2D.disabled=false
	$stand/customizepanel/CollisionShape2D3.disabled=false
	if Global.day == 0:
		spawn_crab()


func on_crab_finished():
	current_order["shape"] = ""
	current_order["color"] = "none"

	selected_shell_id = -1
	selected_color = "none"
	hide_customize_colors()
	for item in purple_shells:
		item.visible = false
	for item in yellow_shells:
		item.visible = false
	for item in pink_shells:
		item.visible = false
	reset_ui()
	crab_present = false
	order_completed = true

	# hide shells
	for shell in shells:
		shell.visible = false

	await get_tree().create_timer(0.8).timeout

	# ONLY spawn another crab if the day is still going
	if day_active:
		spawn_crab()



func end_day():
	day_active = false
	crab_present=false
	
	time_passed = 0.0
	current_hour = 0
	$AnimationPlayer.play("crableave")
	$AnimationPlayer.play("fadeday")
	await $AnimationPlayer.animation_finished
	await get_tree().create_timer(1.0).timeout
	$"end day/pearllabel".visible=true
	Global.pearls_earned = Global.pearls_earned + Global.daily_pearls
	$"end day/pearllabel".text = str(Global.pearls_earned)
	$"end day/Pearl".visible=true
	$timerlabel.visible=false
	$"end day/newday".visible=true
	$"end day/shop".visible=true
	$"end day/label2".visible=true
	$"end day/label3".visible=true
	$"end day/label".visible=true
	$"end day/newday".visible=true
	$"end day/shop".visible=true
	$"end day/newday/CollisionShape2D".disabled=false
	$"end day/shop/CollisionShape2D".disabled=false
	$"end day".visible=true
	$info.visible=true
	$"end day/label2".text = "Shells Sold: " + str(Global.daily_shells)
	$"end day/label".text = "Day: " + str(Global.day)
	$"end day/label3".text = "Pearls Earned: " + str(Global.daily_pearls)
	timerlabel.text = "00:00"
	
	
func shop():
	$"end day/shop".visible=false
	$"end day/label2".visible=false
	$"end day/label3".visible=false
	$"end day/label".visible=false
	$"end day/shop".visible=false
	$"end day/shop/CollisionShape2D".disabled=true
	$"end day/panel4".visible=true
	$"end day/panel5".visible=true
	$"end day/panel6".visible=true
	$"end day/panel".visible=true
	$"end day/panel2".visible=true
	$"end day/panel3".visible=true
	$"end day/panelselect/CollisionShape2D".disabled=false
	$"end day/panelselect/CollisionShape2D2".disabled=false
	$"end day/panelselect/CollisionShape2D3".disabled=false
	$"end day/panelselect/CollisionShape2D4".disabled=false
	$"end day/panelselect/CollisionShape2D5".disabled=false
	$"end day/panelselect/CollisionShape2D6".disabled=false
	
	
	#shop upgrades disable/enable!
	$"end day/panelselect/CollisionShape2D".disabled = Global.upgrades["purple"]
	$"end day/panelselect/CollisionShape2D2".disabled = Global.upgrades["yellow"]
	$"end day/panelselect/CollisionShape2D3".disabled = Global.upgrades["pink"]
	$"end day/panelselect/CollisionShape2D4".disabled = Global.upgrades["barnacle"]
	$"end day/panelselect/CollisionShape2D5".disabled = Global.upgrades["starfish"]
	$"end day/panelselect/CollisionShape2D6".disabled = Global.upgrades["bow"]

	

func new_day():
	$"end day/panelselect/CollisionShape2D".disabled=true
	$"end day/panelselect/CollisionShape2D2".disabled=true
	$"end day/panelselect/CollisionShape2D3".disabled=true
	$"end day/panelselect/CollisionShape2D4".disabled=true
	$"end day/panelselect/CollisionShape2D5".disabled=true
	$"end day/panelselect/CollisionShape2D6".disabled=true
	Global.day +=1 
	$AnimationPlayer.play("fadeinday")
	await $AnimationPlayer.animation_finished
	day_active = true
	respawn_crab()
	
	
func respawn_crab():
	hide_order_request()
	crab_present = false
	order_completed = true

	# reset shells
	for shell in shells:
		shell.visible = false

	await get_tree().create_timer(1.0).timeout
	spawn_crab()

func spawn_crab():	
	selected_shell_id = -1
	selected_color = "none" #reset the collors
	$AnimationPlayer.play("crabenter")
	print("SPAWNING CRAB")
	if crab_textures.is_empty():
		push_error("No crab textures assigned!")
		return

	crab_present = true 
	order_completed = false
	$Crab/Crab.visible = true
	crab_sprite.texture = crab_textures.pick_random()
	await $AnimationPlayer.animation_finished
	crab_order()

func crab_order():
	$stand/customizepanel/CollisionShape2D2.disabled=false
	$stand/customizepanel/CollisionShape2D.disabled=false
	$stand/customizepanel/CollisionShape2D3.disabled=false
	
	$Crab/shell1.position = Vector2(543.0,341)
	$Crab/shell2.position = Vector2(551, 345)
	$Crab/shell3.position = Vector2(561, 300)
	$orderrequest/orderbubble.visible = true
	var shapes = ["shell1", "shell2", "shell3"] 
	current_order["shape"] = shapes.pick_random()
	current_order["color"] = build_color_pool().pick_random()

	if current_order["shape"] == "shell1" :
		$orderrequest/ordershell1.visible=true
		#shell1 crab upgrade posiition
		$Crab/Barnacle2.position = Vector2(352, 280) 
		$Crab/Barnacle2.rotation = -60.2 
		$Crab/Barnacle2.scale = Vector2(0.18, 0.18)
		$Crab/Barnacle.position = Vector2(662.0, 270.0)
		$Crab/Barnacle.scale = Vector2(0.24, 0.24)
		$Crab/Barnacle.rotation = 28
		$Crab/Ribbon.position = Vector2(403.0, 130.0)
		$Crab/Ribbon.scale = Vector2(0.38, 0.38)
		$Crab/Ribbon.rotation = 1.3
		$Crab/Star3.position = Vector2(429, 360.0)
		$Crab/Star3.scale = Vector2(0.31, 0.31)
		$Crab/Star3.rotation = -106.9
		$Crab/Star4.position = Vector2(476, 221.0)
		$Crab/Star4.scale = Vector2(0.15, 0.15)
		$Crab/Star4.rotation = 28.1
		$Crab/Star5.position = Vector2(565.0,305.0)
		$Crab/Star5.scale = Vector2(0.21,0.21)
		$Crab/Star5.rotation = 0
		if current_order["color"]== "purple":
			$orderrequest/ordershell1/purple.visible=true
		elif current_order["color"]== "yellow":
			$orderrequest/ordershell1/yellow.visible=true
		elif current_order["color"] == "pink":
			$orderrequest/ordershell1/pink.visible=true
	if current_order["shape"] == "shell2":
		$orderrequest/ordershell2.visible=true
		#shell2 crab upgrade posiition
		$Crab/Barnacle2.position = Vector2(302, 264.0) 
		$Crab/Barnacle2.scale = Vector2(0.18, 0.18)
		$Crab/Barnacle2.rotation = -60.2
		$Crab/Barnacle.position = Vector2(688.0, 138.0)
		$Crab/Barnacle.scale = Vector2(0.24,0.24)
		$Crab/Barnacle.rotation = 34
		$Crab/Ribbon.position = Vector2(428.0, 156.0)
		$Crab/Ribbon.scale = Vector2(0.45, 0.45)
		$Crab/Ribbon.rotation = -16.2
		$Crab/Star3.position = Vector2(706.0, 358.0)
		$Crab/Star3.scale = Vector2(0.37, 0.37)
		$Crab/Star3.rotation = -106.9
		$Crab/Star4.position = Vector2(376, 325.0)
		$Crab/Star4.scale = Vector2(0.25, 0.25)
		$Crab/Star4.rotation = 28.1
		$Crab/Star5.position = Vector2(596.0,191.0)
		$Crab/Star5.scale = Vector2(0.21, 0.21)
		$Crab/Star5.rotation = 0
		if current_order["color"]== "purple":
			$orderrequest/ordershell2/purple.visible=true
		elif current_order["color"]== "yellow":
			$orderrequest/ordershell2/yellow.visible=true
		elif current_order["color"] == "pink":
			$orderrequest/ordershell2/pink.visible=true
	if current_order["shape"] == "shell3":
		$orderrequest/ordershell3.visible=true
		#shell3 crab upgrade posiition
		$Crab/Barnacle2.position = Vector2(496.0,337) 
		$Crab/Barnacle2.scale = Vector2(0.18, 0.18)
		$Crab/Barnacle2.rotation =-51.4
		$Crab/Barnacle.position = Vector2(688.0, 99.0)
		$Crab/Barnacle.scale = Vector2(0.24, 0.24)
		$Crab/Barnacle.rotation = 38.8
		$Crab/Ribbon.position = Vector2(408.0, 160.0)
		$Crab/Ribbon.scale = Vector2(0.26, 0.26)
		$Crab/Ribbon.rotation =11.9
		$Crab/Star3.position = Vector2(706.0, 358.0)
		$Crab/Star3.scale = Vector2(0.2, 0.2)
		$Crab/Star3.rotation = -38.4
		$Crab/Star4.position = Vector2(408.0, 373.0)
		$Crab/Star4.scale = Vector2(0.25,0.25)
		$Crab/Star4.rotation = 14.8
		$Crab/Star5.position = Vector2(595,178)
		$Crab/Star5.rotation = 0
		$Crab/Star5.scale = Vector2(0.1,0.1)
		if current_order["color"]== "purple":
			$orderrequest/ordershell3/purple.visible=true
		elif current_order["color"]== "yellow":
			$orderrequest/ordershell3/yellow.visible=true
		elif current_order["color"] == "pink":
			$orderrequest/ordershell3/pink.visible=true
	
	print("New order:", current_order)

func build_color_pool() -> Array:
	var pool := ["none", "none"]

	if Global.upgrades["purple"]:
		pool.append("purple")
	if Global.upgrades["yellow"]:
		pool.append("yellow")
	if Global.upgrades["pink"]:
		pool.append("pink")

	return pool


func _on_shell_selected(shell_id):
	
	$stand/customizepanel/CollisionShape2D.disabled = true
	$stand/customizepanel/CollisionShape2D2.disabled = true
	$stand/customizepanel/CollisionShape2D3.disabled = true

	selected_shell_id = shell_id

	for i in range(shells.size()):
		shells[i].visible = (i == shell_id)

	var colors = $stand/customizepanel.get_unlocked_colors()

	if current_order["color"] == "none" or colors.size() == 0:
		check_order()
	else:
		$stand/customizepanel.selecting_color = true
		
		#enable colors
		$stand/customizepanel/purplecoll.disabled = not Global.upgrades["purple"]
		$stand/customizepanel/yellowcoll.disabled = not Global.upgrades["yellow"]
		$stand/customizepanel/pinkcoll.disabled = not Global.upgrades["pink"]
		
		
		#reset_ui()
		## show the color panlelll
		
		purplepanel.visible = Global.upgrades["purple"]
		yellowpanel.visible = Global.upgrades["yellow"]
		pinkpanel.visible = Global.upgrades["pink"]
		
func _on_color_selected(color):

	$stand/customizepanel/purplecoll.disabled = true
	$stand/customizepanel/yellowcoll.disabled = true
	$stand/customizepanel/pinkcoll.disabled = true

	selected_color = color
	apply_color()
	$stand/customizepanel.selecting_color = false
	check_order()

func reset_ui():
	# hide colors
	purplepanel.visible = false
	yellowpanel.visible = false
	pinkpanel.visible = false

	# show shells
	$stand/customizepanel/panel/customizeshell1.visible = true
	$stand/customizepanel/panel2/customizeshell2.visible = true
	$stand/customizepanel/panel3/customizeshell3.visible = true

	
func apply_color():
	for i in range(shells.size()):
		purple_shells[i].position = shells[i].position
		yellow_shells[i].position = shells[i].position
		pink_shells[i].position = shells[i].position
	#print(selected_shell_id)
	
	# hide prev colors first!!
	for item in purple_shells:
		item.visible = false
	for item in yellow_shells:
		item.visible = false
	for item in pink_shells:
		item.visible = false
		
	if selected_shell_id < 0 or selected_shell_id >= shells.size():
		return
		
	for shell in shells:
		shell.visible = false
		
	if selected_color == "purple":
		purple_shells[selected_shell_id].visible = true
	elif selected_color == "yellow":
		yellow_shells[selected_shell_id].visible = true
	elif selected_color == "pink":
		pink_shells[selected_shell_id].visible = true
	
func check_order() -> void:
	if selected_shell_id < 0 or selected_shell_id >= shells.size():
		return
		
	hide_order_request()
	
	$stand/customizepanel/CollisionShape2D2.disabled=true
	$stand/customizepanel/CollisionShape2D.disabled=true
	$stand/customizepanel/CollisionShape2D3.disabled=true
	
	var selected_shell_shape = shells[selected_shell_id].name
	var order_shape = current_order["shape"]
	var order_color = current_order["color"]
	var color_match = (order_color == "none" or selected_color == order_color)

	if selected_shell_shape == order_shape and color_match:
		print("happy")
		if order_failed:
			hide_customize_colors()
			$orderrequest/pearls.visible=true
			$orderrequest/Pearl.visible=true
			Global.daily_pearls += 5
			$orderrequest/pearls.text = "5"
			order_failed = false
		else:
			face.visible = true
			face.texture = happy
			await get_tree().create_timer(2).timeout
			$orderrequest/pearls.visible=true
			$orderrequest/Pearl.visible=true
			face.visible = false
			Global.daily_pearls += 10
			$orderrequest/pearls.text = "10"
		hide_order_request()
		await get_tree().create_timer(2).timeout
		hide_customize_colors()
		$orderrequest/pearls.visible=false
		$orderrequest/Pearl.visible=false
		$orderrequest/orderbubble.visible=false
		Global.daily_shells +=1
		$AnimationPlayer.play("crableave")
		hide_order_request()
		await $AnimationPlayer.animation_finished
		on_crab_finished()

		
	else:
		print("sad")
		order_failed = true
		# show sad face
		face.visible = true
		face.texture = sad
		await get_tree().create_timer(2).timeout
		hide_customize_colors()
		reset_ui()
		hide_all_crab_upgrades()
		face.visible = false
		$orderrequest/orderbubble.visible = true

	if current_order["shape"] == "shell1" :
			$orderrequest/ordershell1.visible=true
			if current_order["color"]== "purple":
				$orderrequest/ordershell1/purple.visible=true
			elif current_order["color"]== "yellow":
				$orderrequest/ordershell1/yellow.visible=true
			elif current_order["color"] == "pink":
				$orderrequest/ordershell1/pink.visible=true
	if current_order["shape"] == "shell2":
		$orderrequest/ordershell2.visible=true
		if current_order["color"]== "purple":
			$orderrequest/ordershell2/purple.visible=true
		elif current_order["color"]== "yellow":
			$orderrequest/ordershell2/yellow.visible=true
		elif current_order["color"] == "pink":
			$orderrequest/ordershell2/pink.visible=true
	if current_order["shape"] == "shell3":
		$orderrequest/ordershell3.visible=true
		if current_order["color"]== "purple":
			$orderrequest/ordershell3/purple.visible=true
		elif current_order["color"]== "yellow":
			$orderrequest/ordershell3/yellow.visible=true
		elif current_order["color"] == "pink":
			$orderrequest/ordershell3/pink.visible=true
	
	$stand/customizepanel/CollisionShape2D2.disabled = false
	$stand/customizepanel/CollisionShape2D.disabled = false
	$stand/customizepanel/CollisionShape2D3.disabled = false


func hide_order_request():
	$orderrequest/ordershell3.visible=false
	$orderrequest/ordershell2.visible=false
	$orderrequest/ordershell1.visible=false
	$orderrequest/ordershell1/purple.visible=false
	$orderrequest/ordershell1/yellow.visible=false
	$orderrequest/ordershell1/pink.visible=false
	$orderrequest/ordershell2/purple.visible=false
	$orderrequest/ordershell2/yellow.visible=false
	$orderrequest/ordershell2/pink.visible=false
	$orderrequest/ordershell3/purple.visible=false
	$orderrequest/ordershell3/yellow.visible=false
	$orderrequest/ordershell3/pink.visible=false
	
func hide_all_crab_upgrades():
	$Crab/shell1.visible=false
	$Crab/shell2.visible=false
	$Crab/shell3.visible=false
	$Crab/purple1.visible=false
	$Crab/purple2.visible=false
	$Crab/purple3.visible=false
	$Crab/yellow1.visible=false
	$Crab/yellow2.visible=false
	$Crab/yellow3.visible=false
	$Crab/pink1.visible=false
	$Crab/pink2.visible=false
	$Crab/pink3.visible=false
	
func hide_customize_colors():
	$stand/customizepanel/panel/purple.visible=false
	$stand/customizepanel/panel2/yellow.visible=false
	$stand/customizepanel/panel3/pink.visible=false
	
	

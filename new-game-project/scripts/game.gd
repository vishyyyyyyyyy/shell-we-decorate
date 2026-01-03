extends Node2D

const DAY_LENGTH := 60
const HOURS := 24
const SECONDS_PER_HOUR := DAY_LENGTH / HOURS
var time_passed := 0.0
var current_hour := 0
var day_active := false
var order_failed := false




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
}

func _ready() -> void:
	$info.visible=true
	$info/Area2D.visible=true
	$Crab/Crab.visible = false
	#end_day()
	$"end day/shop".shop.connect(shop)
	$"end day/newday".newday.connect(new_day)
	$info/Area2D.start.connect(start)
	$stand/customizepanel.shell_selected.connect(_on_shell_selected)


func _process(delta: float) -> void:
	if not day_active:
		return

	time_passed += delta

	var new_hour := int(time_passed / SECONDS_PER_HOUR)

	if new_hour != current_hour:
		current_hour = new_hour
		timerlabel.text = "%02d:00" % current_hour

	if current_hour >= 24:
		end_day()


func start():
	day_active = true
	$stand/customizepanel/CollisionShape2D2.disabled=false
	$stand/customizepanel/CollisionShape2D.disabled=false
	$stand/customizepanel/CollisionShape2D3.disabled=false
	if Global.day == 0:
		spawn_crab()


func on_crab_finished():
	crab_present = false
	order_completed = true

	# hide shells
	for shell in shells:
		shell.visible = false

	await get_tree().create_timer(0.8).timeout

	# ONLY spawn another crab if the day is still going
	if current_hour < 24:
		spawn_crab()



func end_day():
	day_active = false
	
	time_passed = 0.0
	current_hour = 0
	Global.day += 1
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
	$info/Area2D/CollisionShape2D.disabled = false
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
	if Global.updgrades["purple"] == true:
		$"end day/panelselect/CollisionShape2D".disabled=true
	if Global.updgrades["yellow"] == true:
		$"end day/panelselect/CollisionShape2D2".disabled=false
	if Global.updgrades["pink"] == true:
		$"end day/panelselect/CollisionShape2D3".disabled=false
	if Global.updgrades["barnacle"] == true:
		$"end day/panelselect/CollisionShape2D4".disabled=false
	if Global.updgrades["starfish"] == true:
		$"end day/panelselect/CollisionShape2D5".disabled=false
	if Global.updgrades["bow"] == true:
		$"end day/panelselect/CollisionShape2D6".disabled=false
	
		
	#respawn_crab()

func new_day():
	Global.day +=1 
	$AnimationPlayer.play("fadeinday")
	await $AnimationPlayer.animation_finished
	day_active = true
	respawn_crab()
	
	
func respawn_crab():
	crab_present = false
	order_completed = true

	# reset shells
	for shell in shells:
		shell.visible = false

	await get_tree().create_timer(1.0).timeout
	spawn_crab()

func spawn_crab():
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
	
	$Crab/shell1.position.x = 543.0
	$Crab/shell1.position.y = 341
	$Crab/shell2.position.x = 551
	$Crab/shell2.position.y = 345
	$Crab/shell3.position.x = 561
	$Crab/shell3.position.y = 300
	$orderrequest/orderbubble.visible = true
	var shapes = ["shell1", "shell2", "shell3"] 
	current_order["shape"] = shapes.pick_random()
	var color_extras = []
	current_order["color"] = build_color_pool().pick_random()

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


func _on_shell_selected(shell_id: int) -> void:
	for i in range(shells.size()):
		shells[i].visible = (i == shell_id)
		#if Global.updgrades["purple"] == true:
			#pass
	check_order(shell_id)

func check_order(shell_id: int) -> void:
	$stand/customizepanel/CollisionShape2D2.disabled=true
	$stand/customizepanel/CollisionShape2D.disabled=true
	$stand/customizepanel/CollisionShape2D3.disabled=true
	
	var selected_shell_shape = shells[shell_id].name
	var order_shape = current_order["shape"]
	
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

	if selected_shell_shape == order_shape:
		print("happy")
		if order_failed:
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
		await get_tree().create_timer(2).timeout
		$orderrequest/pearls.visible=false
		$orderrequest/Pearl.visible=false
		$orderrequest/orderbubble.visible=false
		Global.daily_shells +=1
		$AnimationPlayer.play("crableave")
		await $AnimationPlayer.animation_finished
		on_crab_finished()

		
	else:
		print("sad")
		order_failed = true
		# show sad face
		face.visible = true
		face.texture = sad
		await get_tree().create_timer(2).timeout
		face.visible = false
		$orderrequest/orderbubble.visible = true

		if order_shape == "shell1":
			$orderrequest/ordershell1.visible = true
		elif order_shape == "shell2":
			$orderrequest/ordershell2.visible = true
		elif order_shape == "shell3":
			$orderrequest/ordershell3.visible = true
			
		$stand/customizepanel/CollisionShape2D2.disabled = false
		$stand/customizepanel/CollisionShape2D.disabled = false
		$stand/customizepanel/CollisionShape2D3.disabled = false

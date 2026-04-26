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
var selected_stars := 0
var selected_barnacle := 0
var selected_bow := 0

@onready var timerlabel = $timerlabel

@export var crab_textures: Array[Texture2D]
@export var special_crab_textures: Array[Texture2D]
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
	"bow": -1,
	"barnacle": -1
}

var selecting_extras := false
var stars = 0
var barnacle = 0
var bow = 0
var total_extras = 0

@onready var purplepanel = $stand/customizepanel/panel/purple
@onready var yellowpanel = $stand/customizepanel/panel2/yellow
@onready var pinkpanel = $stand/customizepanel/panel3/pink

@onready var purple_shells = [$Crab/purple1, $Crab/purple2, $Crab/purple3]
@onready var yellow_shells = [$Crab/yellow1, $Crab/yellow2, $Crab/yellow3]
@onready var pink_shells = [$Crab/pink1, $Crab/pink2, $Crab/pink3]

var fail_counter = 0

var rich_crab = false
var robber_crab = false


func _ready() -> void:
	#purplepanel.visible = Global.upgrades["purple"]
	$info.visible=true
	$Crab/Crab.visible = false
	#end_day()
	$"end day/shop".shop.connect(shop)
	$"end day/newday".newday.connect(new_day)
	$info/Area2D.start.connect(start)
	$stand/customizepanel.shell_selected.connect(_on_shell_selected)
	$stand/customizepanel.color_selected.connect(_on_color_selected)
	$stand/customizepanel.stars_selected.connect(_on_stars_selected)
	$stand/customizepanel.barnacle_selected.connect(_on_barnacle_selected)
	$stand/customizepanel.bow_selected.connect(_on_bow_selected)

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
	$info/Area2D/CollisionShape2D.disabled=true
	$AnimationPlayer.play("fadeinday")
	await $AnimationPlayer.animation_finished
	day_active = true
	$stand/customizepanel/CollisionShape2D2.disabled=false
	$stand/customizepanel/CollisionShape2D.disabled=false
	$stand/customizepanel/CollisionShape2D3.disabled=false
	#if Global.day == 0:
	spawn_crab()


func on_crab_finished():
	rich_crab = false
	robber_crab = false
	current_order["shape"] = ""
	current_order["color"] = "none"
	selected_shell_id = -1
	selected_color = "none"
	selected_barnacle = 0
	selected_bow = 0
	selected_stars = 0
	stars = 0
	barnacle = 0
	bow= 0
	hide_customize_colors()
	hide_customize_extras()
	for item in purple_shells:
		item.visible = false
	for item in yellow_shells:
		item.visible = false
	for item in pink_shells:
		item.visible = false
	$Crab/Barnacle2.visible=false
	$Crab/Barnacle.visible=false
	$Crab/Ribbon.visible=false
	$Crab/Star3.visible=false
	$Crab/Star4.visible=false
	$Crab/Star5.visible=false
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
	hide_order_request()
	await $AnimationPlayer.animation_finished
	await get_tree().create_timer(1.0).timeout
	if Global.day == 10:
		$"last day".visible=true
		$"last day/AnimationPlayer".play("yay")
		$"last day/pearllabel".text = "Total Pearls: " + str(Global.pearls_earned)
		$"last day/shellssoldlabel". text= "Total Shells Sold: " + str(Global.shells_sold)
		$"last day/streaklabel".text = "Longest Streak: " + str(Global.streak)
		$"last day/Area2D/CollisionShape2D".disabled=false
	else:
		$"end day/Infobox".visible=true
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
	if Global.day == 10: #reach day 10
		$stand/AnimationPlayer/achievementtitle.text = Global.achievements["shell_legend"]["name"]
		$stand/AnimationPlayer/pearlsadded.text = "+" +  str(Global.achievements["shell_legend"]["reward"])
		$stand/AnimationPlayer/desc.text = Global.achievements["shell_legend"]["desc"]
		Global.achievements["shell_legend"]["unlocked"] =true
		Global.daily_pearls += 40
		$stand/AnimationPlayer.play("new_achievement")
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
	bow = 0
	barnacle= 0
	stars =0
	hide_order_request()
	selected_shell_id = -1
	selected_color = "none" #reset the collors
	selected_stars = 0
	selected_barnacle = 0
	selected_bow = 0
	$AnimationPlayer.play("crabenter")
	print("SPAWNING CRAB")
	if crab_textures.is_empty():
		push_error("No crab textures assigned!")
		return
	crab_present = true 
	order_completed = false
	$Crab/Crab.visible = true
	var crab_event = [0,0,0,0,0,0,1] #[1]
	if crab_event.pick_random() == 0:
		crab_sprite.texture = crab_textures.pick_random()
		await $AnimationPlayer.animation_finished
		crab_order()
	else:
		var index = randi() % special_crab_textures.size()
		crab_sprite.texture = special_crab_textures[index]
		if index == 0:
			print("rich crab")
			rich_crab = true
			await $AnimationPlayer.animation_finished
			crab_order()
		else:
			print("robber crab")
			robber_crab = true
			await $AnimationPlayer.animation_finished
			robber_crab_shenanigans()

func robber_crab_shenanigans():
	var actions = ["steal pearls"] #["steal pearls", "steal extras"]
	$orderrequest/orderbubble.visible= true
	if actions.pick_random() == "steal pearls":
		$orderrequest/pearls.visible= true
		$orderrequest/Pearl.visible= true
		Global.daily_shells -= 25
		$orderrequest/pearls.text = "-25"
		await get_tree().create_timer(2).timeout
	#else: 
		#var extra = ["color", "star", "barnacle", "bow"]
		#if extra.pick_random() == "color":
			#var color = build_color_pool().pick_random()
			#if color != "none":
				#		
	$orderrequest/pearls.visible= false
	$orderrequest/Pearl.visible= false
	$orderrequest/orderbubble.visible= false
	$AnimationPlayer.play("crableave")
	play_leave_extra_anim()
	await $AnimationPlayer.animation_finished
	await $AnimationPlayer2.animation_finished
	on_crab_finished()

var safelock_total_extras

func crab_order():
	hide_order_request()
	reset_ui()
	
	$Crab/shell1.position = Vector2(543.0,341)
	$Crab/shell2.position = Vector2(551, 345)
	$Crab/shell3.position = Vector2(561, 300)
	$orderrequest/orderbubble.visible = true
	var shapes = ["shell1", "shell2", "shell3"] 
	current_order["shape"] = shapes.pick_random()
	current_order["color"] = build_color_pool().pick_random()
	current_order["stars"] = build_stars_pool().pick_random()
	stars = current_order["stars"]
	current_order["barnacle"] = build_barnacles_pool().pick_random()
	barnacle = current_order["barnacle"]
	current_order["bow"] = build_bow_pool().pick_random()
	bow = current_order["bow"]
	
	#total extras add
	total_extras = stars + barnacle + bow 
	safelock_total_extras = total_extras
	print("total extras: " + str(total_extras))

	if current_order["shape"] == "shell1" :
		$orderrequest/ordershell1.visible=true
		#shell1 crab upgrade posiition
		if current_order["color"]== "purple":
			$orderrequest/ordershell1/purple.visible=true
		elif current_order["color"]== "yellow":
			$orderrequest/ordershell1/yellow.visible=true
		elif current_order["color"] == "pink":
			$orderrequest/ordershell1/pink.visible=true
		$Crab/Barnacle2.position = Vector2(343, 286) 
		$Crab/Barnacle2.rotation_degrees = -64.6
		$Crab/Barnacle2.scale = Vector2(0.299, 0.299)
		
		$Crab/Barnacle.position = Vector2(670, 274)
		$Crab/Barnacle.scale = Vector2(0.266, 0.266)
		$Crab/Barnacle.rotation_degrees = 24.9
		
		$Crab/Ribbon.position = Vector2(411.0, 169.0)
		$Crab/Ribbon.scale = Vector2(0.385, 0.385)
		$Crab/Ribbon.rotation_degrees = -14.0
		
		$Crab/Star3.position = Vector2(397, 367.0)
		$Crab/Star3.scale = Vector2(0.187, 0.187)
		$Crab/Star3.rotation_degrees = -106.9
		
		$Crab/Star4.position = Vector2(579, 330.0)
		$Crab/Star4.scale = Vector2(0.265, 0.265)
		$Crab/Star4.rotation_degrees = 28.1
		
		$Crab/Star5.position = Vector2(476.0,267.0)
		$Crab/Star5.scale = Vector2(0.288,0.288)
		$Crab/Star5.rotation_degrees = 38.8
		
	if current_order["shape"] == "shell2":
		$orderrequest/ordershell2.visible=true
		#shell2 crab upgrade posiition
		if current_order["color"]== "purple":
			$orderrequest/ordershell2/purple.visible=true
		elif current_order["color"]== "yellow":
			$orderrequest/ordershell2/yellow.visible=true
		elif current_order["color"] == "pink":
			$orderrequest/ordershell2/pink.visible=true
		
		$Crab/Barnacle2.position = Vector2(337, 385) 
		$Crab/Barnacle2.rotation_degrees = -64.6
		$Crab/Barnacle2.scale = Vector2(0.299, 0.299)
		
		$Crab/Barnacle.position = Vector2(438, 108)
		$Crab/Barnacle.scale = Vector2(0.266, 0.266)
		$Crab/Barnacle.rotation_degrees = -20.3
		
		$Crab/Ribbon.position = Vector2(717, 237.0)
		$Crab/Ribbon.scale = Vector2(0.385, 0.385)
		$Crab/Ribbon.rotation_degrees = 9.6
		
		$Crab/Star3.position = Vector2(554, 235.0)
		$Crab/Star3.scale = Vector2(0.187, 0.187)
		$Crab/Star3.rotation_degrees = -106.9
		
		$Crab/Star4.position = Vector2(367, 273.0)
		$Crab/Star4.scale = Vector2(0.265, 0.265)
		$Crab/Star4.rotation_degrees = 28.1
		
		$Crab/Star5.position = Vector2(676.0,347.0)
		$Crab/Star5.scale = Vector2(0.161,0.161)
		$Crab/Star5.rotation_degrees = 38.8
	if current_order["shape"] == "shell3":
		$orderrequest/ordershell3.visible=true
		#shell3 crab upgrade posiition
		if current_order["color"]== "purple":
			$orderrequest/ordershell3/purple.visible=true
		elif current_order["color"]== "yellow":
			$orderrequest/ordershell3/yellow.visible=true
		elif current_order["color"] == "pink":
			$orderrequest/ordershell3/pink.visible=true
			
		$Crab/Barnacle2.position = Vector2(657.365, 326.197) 
		$Crab/Barnacle2.rotation_degrees = 41
		$Crab/Barnacle2.scale = Vector2(0.299, 0.299)
		
		$Crab/Barnacle.position = Vector2(620, 61)
		$Crab/Barnacle.scale = Vector2(0.133, 0.133)
		$Crab/Barnacle.rotation_degrees = -46.6
		
		$Crab/Ribbon.position = Vector2(509, 318)
		$Crab/Ribbon.scale = Vector2(0.306, 0.306)
		$Crab/Ribbon.rotation_degrees = 9.6
		
		$Crab/Star3.position = Vector2(556, 230)
		$Crab/Star3.scale = Vector2(0.187, 0.187)
		$Crab/Star3.rotation_degrees = -106.9
		
		$Crab/Star4.position = Vector2(646, 261.0)
		$Crab/Star4.scale = Vector2(0.158, 0.158)
		$Crab/Star4.rotation_degrees = 28.1
		
		$Crab/Star5.position = Vector2(658.0, 139.0)
		$Crab/Star5.scale = Vector2(0.209,0.209)
		$Crab/Star5.rotation_degrees = 38.8
	
	if stars == 3:
		$orderrequest/Star.visible = true
		$orderrequest/Star3.visible = true
		$orderrequest/Star2.visible = true
	elif stars == 2:
		$orderrequest/Star.visible = true
		$orderrequest/Star2.visible = true
	elif stars == 1:
		$orderrequest/Star3.visible = true
	else:
		pass
	
	if barnacle == 2:
		$orderrequest/Barnacle.visible = true
		$orderrequest/Barnacle2.visible = true
	elif barnacle == 1:
		$orderrequest/Barnacle.visible = true
	else:
		pass
	
	if bow == 1:
		$orderrequest/Ribbon.visible=true
	else:
		pass
	
	print("New order:", current_order)
	
	if crab_present:
		$stand/customizepanel/CollisionShape2D2.disabled=false
		$stand/customizepanel/CollisionShape2D.disabled=false
		$stand/customizepanel/CollisionShape2D3.disabled=false

func build_color_pool() -> Array:
	var pool: Array = []
	if Global.day >= 7:
		pool = ["none"]
	elif Global.day >=4:
		pool = ["none", "none"]
	else:
		pool = ["none", "none", "none"]

	if Global.upgrades["purple"]:
		pool.append("purple")
	if Global.upgrades["yellow"]:
		pool.append("yellow")
	if Global.upgrades["pink"]:
		pool.append("pink")

	return pool
	
func build_stars_pool() -> Array:
	var pool: Array = []
	if Global.day >= 7:
		pool = [0]
	elif Global.day >=4:
		pool = [0,0]
	else:
		pool = [0,0,0]

	if Global.upgrades["starfish"]:
		pool.append(1)
		pool.append(1)
		pool.append(1)
		pool.append(2)
		pool.append(2)
		pool.append(3)

	return pool
	
func build_barnacles_pool() -> Array:
	var pool: Array = []
	if Global.day >= 7:
		pool = [0]
	elif Global.day >=4:
		pool = [0,0]
	else:
		pool = [0,0,0]
		
	if Global.upgrades["barnacle"]:
		pool.append(1)
		pool.append(1)
		pool.append(2)
	return pool
	
func build_bow_pool() -> Array:
	var pool: Array = []
	if Global.day >= 7:
		pool = [0]
	elif Global.day >=4:
		pool = [0,0]
	else:
		pool = [0,0,0]
		
	if Global.upgrades["bow"]:
		pool.append(1)
	return pool


func _on_shell_selected(shell_id):
	$stand/customizepanel/CollisionShape2D.disabled = true
	$stand/customizepanel/CollisionShape2D2.disabled = true
	$stand/customizepanel/CollisionShape2D3.disabled = true

	selected_shell_id = shell_id

	for i in range(shells.size()):
		shells[i].visible = (i == shell_id)

	var colors = $stand/customizepanel.get_unlocked_colors()

	if current_order["color"] == "none" and bow == 0 and stars == 0 and barnacle ==0:
		check_order()
	else:
		#enable colors
		if current_order["color"] == "none":
			$stand/customizepanel.selecting_color = false
			selecting_extras = true
			$stand/customizepanel/starcoll.disabled = not Global.upgrades["starfish"]
			$stand/customizepanel/barnaclecoll.disabled = not Global.upgrades["barnacle"]
			$stand/customizepanel/bowcoll.disabled = not Global.upgrades["bow"]
			$stand/customizepanel/panel/customizeshell1.visible=false
			$stand/customizepanel/panel2/customizeshell2.visible=false
			$stand/customizepanel/panel3/customizeshell3.visible=false
			$stand/customizepanel/Star3.visible=Global.upgrades["starfish"]
			$stand/customizepanel/Star4.visible=Global.upgrades["starfish"]
			$stand/customizepanel/Star5.visible=Global.upgrades["starfish"]
			$stand/customizepanel/Barnacle.visible = Global.upgrades["barnacle"]
			$stand/customizepanel/Barnacle2.visible = Global.upgrades["barnacle"]
			$stand/customizepanel/Ribbon.visible = Global.upgrades["bow"]
		
		else:
			$stand/customizepanel.selecting_color = true
			$stand/customizepanel/purplecoll.disabled = not Global.upgrades["purple"]
			$stand/customizepanel/yellowcoll.disabled = not Global.upgrades["yellow"]
			$stand/customizepanel/pinkcoll.disabled = not Global.upgrades["pink"]
			$stand/customizepanel/panel/customizeshell1.visible=false
			$stand/customizepanel/panel2/customizeshell2.visible=false
			$stand/customizepanel/panel3/customizeshell3.visible=false
			#show the color panlelll
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
	if current_order["bow"] == 0 and stars == 0 and barnacle ==0:
		check_order()
	else:
		selecting_extras = true
		print("test2")
		
		hide_customize_colors()
		$stand/customizepanel/panel3/customizeshell3.visible=false
		$stand/customizepanel/panel2/customizeshell2.visible=false
		$stand/customizepanel/panel/customizeshell1.visible=false
		
		$stand/customizepanel/starcoll.disabled = not Global.upgrades["starfish"]
		$stand/customizepanel/barnaclecoll.disabled = not Global.upgrades["barnacle"]
		$stand/customizepanel/bowcoll.disabled = not Global.upgrades["bow"]
		$stand/customizepanel/Star3.visible=Global.upgrades["starfish"]
		$stand/customizepanel/Star4.visible=Global.upgrades["starfish"]
		$stand/customizepanel/Star5.visible=Global.upgrades["starfish"]
		$stand/customizepanel/Barnacle.visible = Global.upgrades["barnacle"]
		$stand/customizepanel/Barnacle2.visible = Global.upgrades["barnacle"]
		$stand/customizepanel/Ribbon.visible = Global.upgrades["bow"]

func _on_stars_selected(count):
	total_extras -=1
	selected_stars += 1  
	if selected_stars == 1:
		$Crab/Star3.visible=true
	
	if selected_stars == 2:
		$Crab/Star3.visible=true
		$Crab/Star4.visible=true
	
	if selected_stars == 3:
		$Crab/Star3.visible=true
		$Crab/Star4.visible=true
		$Crab/Star5.visible=true
	apply_extras()

	if selected_stars == 3:
		$stand/customizepanel/starcoll.disabled = true

	if $stand/customizepanel/starcoll.disabled and $stand/customizepanel/barnaclecoll.disabled and $stand/customizepanel/bowcoll.disabled:
		check_order()
	
	if total_extras <=0:
		print("checking order from stars")
		check_order()

func _on_barnacle_selected(count):
	print("selected_barnacle: ", selected_barnacle)
	print("barnacle available: ", barnacle)
	total_extras -=1
	selected_barnacle += 1
	if selected_barnacle == 1:
		$orderrequest/Barnacle.visible=true
	
	if selected_barnacle == 2:
		$orderrequest/Barnacle.visible=true
		$orderrequest/Barnacle2.visible=true
		
	apply_extras()

	if selected_barnacle >= barnacle:
		$stand/customizepanel/barnaclecoll.disabled = true

	if $stand/customizepanel/starcoll.disabled and $stand/customizepanel/barnaclecoll.disabled and $stand/customizepanel/bowcoll.disabled:
		check_order()
	
	if total_extras <=0:
		print("checking order from banracles")
		check_order()

func _on_bow_selected(enabled):
	total_extras -=1
	selected_bow = true
	apply_extras()

	$stand/customizepanel/bowcoll.disabled = true

	if $stand/customizepanel/starcoll.disabled and $stand/customizepanel/barnaclecoll.disabled and $stand/customizepanel/bowcoll.disabled:
		check_order()
		
	if total_extras <=0:
		print("checking order from bow")
		check_order()


func reset_ui():
	#hide extras
	hide_customize_extras()
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
		
func apply_extras():
	# reset all extras first
	$Crab/Star3.visible = false
	$Crab/Star4.visible = false
	$Crab/Star5.visible = false
	$Crab/Barnacle.visible = false
	$Crab/Barnacle2.visible = false
	$Crab/Ribbon.visible = false

	# apply stars
	if selected_stars >= 1:
		$Crab/Star3.visible = true
	if selected_stars >= 2:
		$Crab/Star4.visible = true
	if selected_stars >= 3:
		$Crab/Star5.visible = true

	# apply barnacles
	if selected_barnacle >= 1:
		$Crab/Barnacle.visible = true
	if selected_barnacle == 2:
		$Crab/Barnacle2.visible = true

	# apply bow
	if selected_bow:
		$Crab/Ribbon.visible = true
	
func check_order() -> void:
	if selected_shell_id < 0 or selected_shell_id >= shells.size():
		return
		
	hide_order_request()
	
	$stand/customizepanel/CollisionShape2D2.disabled=true
	$stand/customizepanel/CollisionShape2D.disabled=true
	$stand/customizepanel/CollisionShape2D3.disabled=true
	$stand/customizepanel/purplecoll.disabled=true
	$stand/customizepanel/yellowcoll.disabled=true
	$stand/customizepanel/pinkcoll.disabled=true
	$stand/customizepanel/barnaclecoll.disabled=true
	$stand/customizepanel/starcoll.disabled=true
	$stand/customizepanel/bowcoll.disabled=true
	
	var selected_shell_shape = shells[selected_shell_id].name
	var order_shape = current_order["shape"]
	var order_color = current_order["color"]
	var color_match = (order_color == "none" or selected_color == order_color)

	var stars_match = (stars == selected_stars)
	var barnacle_match = (barnacle == selected_barnacle)
	var bow_match = (bow == selected_bow)
	
	var bonus = 0
	
	if selected_shell_shape == order_shape and color_match and stars_match and barnacle_match and bow_match:
		print("happy")
		if order_failed:
			hide_customize_colors()
			hide_customize_extras()
			fail_counter +=1
			if fail_counter == 3:
				$stand/AnimationPlayer/achievementtitle.text = Global.achievements["chaos_mode"]["name"]
				$stand/AnimationPlayer/pearlsadded.text = "+" +  str(Global.achievements["chaos_mode"]["reward"])
				$stand/AnimationPlayer/desc.text = Global.achievements["chaos_mode"]["desc"]
				Global.achievements["chaos_mode"]["unlocked"] =true
				Global.daily_pearls += 1
				$stand/AnimationPlayer.play("new_achievement")
				
			$orderrequest/pearls.visible=true
			$orderrequest/Pearl.visible=true
			if rich_crab:
				Global.daily_pearls += 30
				$orderrequest/pearls.text = "30"
			else:
				Global.daily_pearls += 5
				$orderrequest/pearls.text = "5"
			order_failed = false
		else:
			Global.streak +=1
			
			if Global.streak == 10: #10x streak orders
				var ach = Global.achievements["flawless_day"]
				ach["unlocked"] = true
				$stand/AnimationPlayer/achievementtitle.text = ach["name"]
				$stand/AnimationPlayer/pearlsadded.text = "+" +  str(ach["reward"])
				$stand/AnimationPlayer/desc.text = ach["desc"]
				Global.daily_pearls += 10
				$stand/AnimationPlayer.play("new_achievement")
				
				#all extras on order
			if Global.achievements["maxed_out"]["unlocked"] == false and current_order["color"] != "" \
				and current_order["stars"] != 0 and current_order["bow"] ==1 and \
				current_order["barnacle"] != 0:

				$stand/AnimationPlayer/achievementtitle.text = Global.achievements["maxed_out"]["name"]
				$stand/AnimationPlayer/pearlsadded.text = "+" +  str(Global.achievements["maxed_out"]["reward"])
				$stand/AnimationPlayer/desc.text = Global.achievements["maxed_out"]["desc"]
				Global.achievements["maxed_out"]["unlocked"] =true
				Global.daily_pearls += 30
				$stand/AnimationPlayer.play("new_achievement")
				
			#calc bonus for addons #color
			if current_order["color"] != "none" and selected_color == current_order["color"]:
				bonus += 2

			# stars bonus
			if selected_stars == current_order["stars"] and selected_stars > 0:
				bonus += 2 * selected_stars

			# barnacle bonus
			if selected_barnacle == current_order["barnacle"] and selected_barnacle > 0:
				bonus += 3 * selected_barnacle

			# bow bonus
			if selected_bow == current_order["bow"] and selected_bow == 1:
				bonus += 5

			face.visible = true
			face.texture = happy
			await get_tree().create_timer(2).timeout
			
			$orderrequest/pearls.visible=true
			$orderrequest/Pearl.visible=true
			face.visible = false
			if rich_crab:
				Global.daily_pearls += 60 + bonus
				$orderrequest/pearls.text = str(60 + bonus)
			else:
				Global.daily_pearls += 10 + bonus
				$orderrequest/pearls.text = str(10 + bonus)
		Global.crabsales +=1 
		selected_barnacle = 0
		selected_bow = 0
		selected_stars = 0
		stars = 0
		bow = 0
		barnacle = 0
		await get_tree().create_timer(2).timeout
		hide_customize_colors()
		hide_customize_extras()
		$orderrequest/pearls.visible=false
		$orderrequest/Pearl.visible=false
		$orderrequest/orderbubble.visible=false
		Global.daily_shells +=1
		$AnimationPlayer.play("crableave")
		play_leave_extra_anim()
		await $AnimationPlayer.animation_finished
		await $AnimationPlayer2.animation_finished
		on_crab_finished()

		
	else:
		print("sad")
		Global.streak = 0
		order_failed = true
		# show sad face
		face.visible = true
		face.texture = sad
		total_extras = safelock_total_extras
		selected_barnacle = 0
		selected_bow = 0
		selected_stars = 0
		#stars = 0
		#barnacle = 0
		await get_tree().create_timer(2).timeout
		hide_customize_colors()
		hide_customize_extras()
		reset_ui()
		hide_all_crab_upgrades()
		face.visible = false
		$orderrequest/orderbubble.visible = true
		$stand/customizepanel/CollisionShape2D2.disabled = false
		$stand/customizepanel/CollisionShape2D.disabled = false
		$stand/customizepanel/CollisionShape2D3.disabled = false

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
	
	if stars == 3:
		$orderrequest/Star.visible = true
		$orderrequest/Star3.visible = true
		$orderrequest/Star2.visible = true
	elif stars == 2:
		$orderrequest/Star.visible = true
		$orderrequest/Star2.visible = true
	elif stars == 1:
		$orderrequest/Star3.visible = true
	else:
		pass
	
	if barnacle == 2:
		$orderrequest/Barnacle.visible = true
		$orderrequest/Barnacle2.visible = true
	elif barnacle == 1:
		$orderrequest/Barnacle.visible = true
	else:
		pass
	
	if bow == 1:
		$orderrequest/Ribbon.visible=true
	else:
		pass


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
	$orderrequest/Barnacle2.visible=false
	$orderrequest/Barnacle.visible=false
	$orderrequest/Star.visible=false
	$orderrequest/Star3.visible =false
	$orderrequest/Star2.visible=false
	$orderrequest/Ribbon.visible=false
	
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
	$Crab/Barnacle2.visible=false
	$Crab/Barnacle.visible=false
	$Crab/Ribbon.visible=false
	$Crab/Star3.visible=false
	$Crab/Star4.visible=false
	$Crab/Star5.visible=false
	
func hide_customize_colors():
	$stand/customizepanel/panel/purple.visible=false
	$stand/customizepanel/panel2/yellow.visible=false
	$stand/customizepanel/panel3/pink.visible=false


func hide_customize_extras():
	$stand/customizepanel/Barnacle2.visible=false
	$stand/customizepanel/Barnacle.visible=false
	$stand/customizepanel/Star4.visible=false
	$stand/customizepanel/Star5.visible=false
	$stand/customizepanel/Star3.visible=false
	$stand/customizepanel/Ribbon.visible=false

func play_leave_extra_anim():
	if current_order["shape"] == "shell1":
		$AnimationPlayer2.play("extra_leave1")
	elif current_order["shape"] == "shell2":
		$AnimationPlayer2.play("extra_leave2")
	else:
		$AnimationPlayer2.play("extra_leave3")

extends Node2D

const DAY_LENGTH := 180.0
const HOURS := 24
const SECONDS_PER_HOUR := DAY_LENGTH / HOURS

@onready var timerlabel = $timerlabel

@export var crab_textures: Array[Texture2D]
@onready var crab_sprite: Sprite2D = $Crab

@onready var face: Sprite2D = $face
@export var happy: Texture2D
@export var sad: Texture2D

@onready var shells := [
	$shell1,
	$shell2,
	$shell3
]

@onready var pearls = $pearls

var crab_present := false
var order_completed := true

var current_order = {
	"shape": "", 
}

func _ready() -> void:
	$Area2D.visible=true
	$Infobox.visible=true
	$label2.visible=true
	$label.visible=true
	
	$Crab.visible = false
	$Area2D.start.connect(start)
	$customizepanel.shell_selected.connect(_on_shell_selected)
	#spawn_crab()

func start():
	$customizepanel/CollisionShape2D2.disabled=false
	$customizepanel/CollisionShape2D.disabled=false
	$customizepanel/CollisionShape2D3.disabled=false
	if Global.day == 0:
		spawn_crab()

func spawn_crab():
	$AnimationPlayer.play("crabenter")
	print("SPAWNING CRAB")
	if crab_textures.is_empty():
		push_error("No crab textures assigned!")
		return

	crab_present = true 
	order_completed = false
	$Crab.visible = true
	crab_sprite.texture = crab_textures.pick_random()
	await $AnimationPlayer.animation_finished
	crab_order()

func crab_order():
	$orderbubble.visible = true
	var shapes = ["shell1", "shell2", "shell3"] 
	current_order["shape"] = shapes.pick_random()
	
	
	if current_order["shape"] == "shell1":
		$ordershell1.visible=true
	elif current_order["shape"] == "shell2":
		$ordershell2.visible=true
	elif current_order["shape"] == "shell3":
		$ordershell3.visible=true
	
	print("New order:", current_order)

func _on_shell_selected(shell_id: int) -> void:
	for i in range(shells.size()):
		shells[i].visible = (i == shell_id)
	
	check_order(shell_id)

func check_order(shell_id: int) -> void:
	$customizepanel/CollisionShape2D2.disabled=true
	$customizepanel/CollisionShape2D.disabled=true
	$customizepanel/CollisionShape2D3.disabled=true
	
	var selected_shell_shape = shells[shell_id].name
	var order_shape = current_order["shape"]
	
	$ordershell3.visible=false
	$ordershell2.visible=false
	$ordershell1.visible=false

	if selected_shell_shape == order_shape:
		print("happy")
		face.visible = true
		face.texture = happy
		await get_tree().create_timer(2).timeout
		face.visible = false
		Global.pearls += 10
		$pearls.visible=true
		$pearls.text = "10"
		$Pearl.visible=true
		await get_tree().create_timer(2).timeout
		$pearls.visible=false
		$Pearl.visible=false
		$orderbubble.visible=false
		$AnimationPlayer.play("crableave")
		
		
	else:
		print("sad")
		face.visible = true
		face.texture = sad
		await get_tree().create_timer(2).timeout
		face.visible = false
		Global.pearls += 5
		$pearls.visible=true
		$pearls.text = "5"
		$Pearl.visible=true
		await get_tree().create_timer(2).timeout
		$pearls.visible=false
		$Pearl.visible=false
		$orderbubble.visible=false
		$AnimationPlayer.play("crableave")
		

extends Node2D

func _ready() -> void:
	$Area2D.start.connect(start)

func start():
	pass
	

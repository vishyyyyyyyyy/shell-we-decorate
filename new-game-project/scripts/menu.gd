extends Node2D

func _ready() -> void:
	Global.upgrades = {
		"purple": false,
		"yellow": false,
		"pink": false,
		"starfish": false,
		"barnacle": false,
		"bow": false
	}

	Global.day = 0
	Global.shells_sold = 0
	Global.daily_shells =0
	Global.pearls_earned = 0
	Global.daily_pearls = 0 
	Global.streak = 0
	Global.crabsales =0 

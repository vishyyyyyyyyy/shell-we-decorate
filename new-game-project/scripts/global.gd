extends Node

var upgrades = {
	"purple": false,
	"yellow": false,
	"pink": false,
	"starfish": false,
	"barnacle": false,
	"bow": false
}

var day := 0
var shells_sold := 0
var daily_shells :=0
var pearls_earned := 0
var daily_pearls := 0 

var streak = 0
var crabsales =0 

var music_on := false
var music_player: AudioStreamPlayer

var achievements = {
	"flawless_day": {
		"name": "Flawless Day",
		"desc": "Serve 10x perfect orders",
		"reward": 10,
		"unlocked": false
	},

	"maxed_out": {
		"name": "Maxed Out",
		"desc": "Complete an order with all extras",
		"reward": 30,
		"unlocked": false
	},

	"shell_legend": {
		"name": "Shell Legend",
		"desc": "Reach day 10",
		"reward": 40,
		"unlocked": false
	},
	
	"chaos_mode": {
		"name": "Chaos Mode",
		"desc": "Fail 3 orders in a row",
		"reward": 1,
		"unlocked": false
	},
	"???": {
		"name": "???",
		"desc": "Achievement Locked",
		"reward": 60,
		"unlocked": false
	},
	"extra": {
		"name": "???",
		"desc": "Achievment Locked",
		"reward": 100,
		"unlocked": false
	}
}

func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	add_child(music_player)

	var music = preload("res://music.mp3")
	music.loop = true
	
	music_player.stream = music
	
	if music_on:
		music_player.play()

func toggle_music():
	music_on = !music_on
	
	if music_on:
		music_player.play()
	else:
		music_player.stop()

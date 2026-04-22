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

var music_on := true
var music_player: AudioStreamPlayer

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

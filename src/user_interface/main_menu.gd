extends Control

onready var players: Button = $Margin/VBoxContainer/Players
onready var play: Button = $Margin/VBoxContainer/Play

signal players_changed(amount)


func _ready() -> void:
	players.grab_focus()
	
	yield(get_tree(), "idle_frame")
	_on_Players_pressed()


func _on_Players_pressed() -> void:
	if players.text == "1 PLAYER":
		players.text = "2 PLAYERS"
		emit_signal("players_changed", 2)
	else:
		players.text = "1 PLAYER"
		emit_signal("players_changed", 1)


func _on_Play_pressed() -> void:
	hide()


func _on_MediaLink_pressed() -> void:
	OS.shell_open("https://gamedev-byhobby.itch.io/")

extends Node3D 
class_name Game

var score: int = 0

func _ready() -> void:
	add_points(0)

func add_points(points: int) -> void:
	score += points
	var label = %Score as Label
	label.text = "Score: " + str(score) + " "

func _on_ring_pin_scored(points: int) -> void:
	add_points(points)

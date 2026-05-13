extends CanvasLayer
@onready var bable: Label = $Control/VBoxContainer/Label



func healthval(health:int):
	bable.text = "health: " + str(health)

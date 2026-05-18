extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@onready var spriframe: AnimatedSprite2D = $spriframe


enum state{idle,moving}

var State : state = state.idle
var totaltimer = 0.0
func _physics_process(delta: float) -> void:
	totaltimer += delta
	
	spriframe.position.y = sin(totaltimer) * 50
	
	
	
	match State:
		pass
		

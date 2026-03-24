extends CharacterBody2D


@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var groundedswordbox: Area2D = $groundedswordbox











var SPEED = 400.0
const JUMP_VELOCITY = -400.0


enum state {idle,moving,attacking,dashing,dashattacking, jumping, airattacking,falling}

enum airbornstate{grounded, falling}

var current : state = state.idle
var aircurrent: airbornstate = airbornstate.falling
var dashtimer := 20.0
var dtb:= dashtimer
var airdash := true



var prevdir := 1.0



func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		aircurrent = airbornstate.falling
	if is_on_floor():
		airdash = true
		aircurrent = airbornstate.grounded 
	
	
	
	var direction := Input.get_axis("moveleft","moveright")
	match current:
		state.moving:
			if direction == -1:
				animated_sprite_2d.flip_h = 1
			elif direction == 1:
				animated_sprite_2d.flip_h = 0
			velocity.x = direction * SPEED
			if direction != 0.0:
				prevdir = direction
		state.dashing:
			#print("dash")
			if prevdir == -1:
				animated_sprite_2d.flip_h = 1
			elif prevdir == 1:
				animated_sprite_2d.flip_h = 0
			
			velocity.x = prevdir * SPEED *5
			dashtimer -= delta* 100
				
			print(dashtimer)
			velocity.y = 0
			if dashtimer > dtb/20:
				if Input.is_action_just_pressed("swing") && aircurrent == airbornstate.grounded:
					current = state.dashattacking
			if dashtimer <= 0:
				print(aircurrent)
				if aircurrent == airbornstate.falling:
					velocity.x = clampf(velocity.x,-SPEED/1.2,SPEED/1.2)
					current = state.falling
					
				else:
					current= state.idle
				dashtimer = dtb
		state.jumping:
			#print("jump")
			aircurrent = airbornstate.falling
			if is_on_floor():
				velocity.y -= 500
			if velocity.y < 0:
				current = state.falling
		state.dashattacking:
			groundedswordbox.monitoring = true
			
			if dashtimer <= 0:
				groundedswordbox.monitoring = false
				print(aircurrent)
				if aircurrent == airbornstate.falling:
					velocity.x = clampf(velocity.x,-SPEED/1.2,SPEED/1.2)
					current = state.falling
		state.falling:
			#print("falling")
			var accel = direction * SPEED * delta*10
			if momentconserv(accel):
				velocity.x += accel
			
			if direction != 0.0:
				prevdir = direction
			if is_on_floor():
				current = state.idle
		_:
			#print("idle/default")
			dashtimer = dtb
			velocity.x = move_toward(velocity.x, 0, SPEED)
		
		
	match aircurrent:

		airbornstate.grounded:
			if current != state.dashing:
				if direction != 0:
					current = state.moving
			if Input.is_action_just_pressed("dash"):
				current = state.dashing
				velocity.y = 0
			
			
			if Input.is_action_just_pressed("jump"):
				
				current = state.jumping
				aircurrent = airbornstate.falling
				dashtimer = dtb
				
			if Input.is_action_pressed("movementkeys") == false:
				
				current = state.idle
				
			
		airbornstate.falling:
			if Input.is_action_just_pressed("dash"):
				if airdash:
					current = state.dashing
					airdash= !airdash
			if dashtimer == dtb && Input.is_action_pressed("movementkeys") == false:
				current = state.falling
	
	
	
	
	##print("playerint state: 	"+ str(current))
	##print("airborne:	 " +str(aircurrent))
	move_and_slide()



func momentconserv(acc: float)-> bool:
	##print("vel:" + str(velocity.x))
	##print("acc:" + str(acc))
	##print(SPEED/1.5)
	if abs(velocity.x + acc) < SPEED/1.5 || abs(velocity.x + acc) < abs(velocity.x):
		return true
	return false

extends CharacterBody2D


var SPEED = 400.0
const JUMP_VELOCITY = -400.0

enum state {idle,moving,attacking,dashing,dashattacking, jumping, airattacking,falling}

enum airbornstate{grounded, falling}

var current : state = state.idle
var aircurrent: airbornstate = airbornstate.falling
var dashtimer := 40.0
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
			print("move")
			velocity.x = direction * SPEED
			if prevdir != 0:
				prevdir = direction
		state.dashing:
			#print("dash")
			velocity.x = prevdir * SPEED * 4
			dashtimer -= delta* 100
			#print(dashtimer)
			print(prevdir)
			velocity.y = 0
			if dashtimer > dtb/20:
				if Input.is_action_just_pressed("swing"):
					current = state.dashattacking
			if dashtimer <= 0:
				if aircurrent == airbornstate.falling:
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
			current = state.idle
		state.falling:
			#print("falling")
			var accel = direction * SPEED * delta*10
			if momentconserv(accel):
				velocity.x += accel
			
			if direction != 0:
				prevdir = direction
			if is_on_floor():
				current = state.idle
		_:
			#print("idle/default")
			dashtimer = dtb
			SPEED= 300.0
			velocity.x = move_toward(velocity.x, 0, SPEED)
		
		
	match aircurrent:

		airbornstate.grounded:
			if current != state.dashing:
				if direction != 0:
					current = state.moving
			if Input.is_action_just_pressed("dash"):
				current = state.dashing
			
			
			if Input.is_action_just_pressed("jump"):
				current = state.jumping
				aircurrent = airbornstate.falling
				
			if Input.is_action_pressed("movementkeys") == false:
				
				current = state.idle
				
			
		airbornstate.falling:
			if Input.is_action_just_pressed("dash"):
				if airdash:
					current = state.dashing
					airdash= !airdash
			if dashtimer != dtb && Input.is_action_pressed("movementkeys") == false:
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

extends CharacterBody2D


var SPEED = 300.0
const JUMP_VELOCITY = -400.0

enum state {idle,moving,attacking,dashing,dashattacking, jumping, airattacking,falling}

var current : state = state.idle
var dashtimer := 20.0
var dtb:= dashtimer

var prevdir := 1.0



func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		current = state.falling
		
	
	
	
	var direction := Input.get_axis("moveleft","moveright")
	
	match current:
		state.moving:
			velocity.x = direction * SPEED
			prevdir = direction
		state.dashing:
			velocity.x = prevdir * SPEED * 4
			dashtimer -= delta* 100
			velocity.y = 0
			if dashtimer > dtb/20:
				if Input.is_action_just_pressed("swing"):
					current = state.dashattacking
			if dashtimer <= 0:
				current= state.idle
				dashtimer = dtb
				
				
				
		state.jumping:
			
			if is_on_floor():
				
				velocity.y -= 500
				
			
			
		state.dashattacking:
			current = state.idle
		
		state.falling:
			
			velocity += get_gravity() * delta
			var accel = direction * SPEED * delta*5
			if momentcancel(accel):
				velocity.x = clampf(velocity.x,-SPEED/1.5,SPEED/1.5)
			else:
				velocity.x += accel
				
			
				
			if is_on_floor():
				current = state.idle
			
			
			
			
			
			
		_:
			dashtimer = 20.0
			SPEED= 300.0
			velocity.x = move_toward(velocity.x, 0, SPEED)
		
		
	
	
	if Input.is_action_just_pressed("dash"):
		current = state.dashing
	
	
	if Input.is_action_just_pressed("jump"):
		current = state.jumping
	
	
	if current == state.idle:
		if direction != 0:
			current = state.moving
	
	
	
	
	
		if Input.is_action_pressed("movementkeys") == false:
			current = state.idle
	
	#print(current)
	move_and_slide()



func momentcancel(acc: float)-> bool:
	if abs(velocity.x) + abs(acc) > SPEED/1.5 && abs(velocity.x) < SPEED/1.5:
		return true
	return false

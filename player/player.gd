extends CharacterBody2D
class_name Player

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@onready var groundedswordbox: Area2D = $groundedswordbox

@onready var attacktimer: Timer = $attacktimer




var var_health : float :
	set(new_health):
		var_health = new_health
		if var_health <= 0:
			queue_free()






var SPEED = 400.0
var jumpdefault=1200.0
var JUMP_VELOCITY = jumpdefault


enum state {idle,moving,attacking,dashing,dashattacking, jumping, airattacking,falling}

enum airbornstate{grounded, falling}

var current : state = state.idle
var aircurrent: airbornstate = airbornstate.falling
var dashtimer := 20.0
var dtb:= dashtimer
var airdash := true
var coytimedef:= 2.0
var coyotetimer := coytimedef





@onready var wallright: RayCast2D = $wallright
@onready var wallleft: RayCast2D = $wallleft




var prevdir := 1.0


signal nextgen()

var grav = 9.8


func _physics_process(delta: float) -> void:
	
	
	
	
	
	
	
	
	
	
	
	# Add the gravity.
	if not is_on_floor():
		coyotetimer -= delta
		if Input.is_action_pressed("jump"):
			grav = 980/1.5
		elif Input.is_action_pressed("FALL"):
			grav = 980*1.5
		else:
			grav = 980
		if velocity.y < 1000 || Input.is_action_pressed("FALL"):
			velocity.y += grav * delta * 2.5
		
		if is_on_wall():
			if velocity.y > 400:
				velocity.y = 400
		aircurrent = airbornstate.falling
	if is_on_floor():
		
		coyotetimer = coytimedef
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
				
			
			velocity.y = 0
			if dashtimer <= 0 || velocity.x == 0:
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
				velocity.y = -JUMP_VELOCITY
			#if is_on_wall_only():
				#airdash = true
				#dashtimer = dtb
				#velocity.y = -JUMP_VELOCITY/1.5
			if wallright.is_colliding() && (is_on_floor() == false):
				airdash = true
				dashtimer = dtb
				velocity.y = -JUMP_VELOCITY/1.5
				print("right")
				velocity.x = -SPEED*2
			if wallleft.is_colliding() && (is_on_floor() == false):
				print("left")
				airdash = true
				dashtimer = dtb
				velocity.y = -JUMP_VELOCITY/1.5
				velocity.x = SPEED*2
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
		
		
	if direction != 0.0:
		groundedswordbox.position = Vector2(95 * direction,0)
		print(groundedswordbox.position)
	match aircurrent:

		airbornstate.grounded:
			if current != state.dashing:
				if direction != 0:
					current = state.moving
			if Input.is_action_just_pressed("dash"):
				current = state.dashing
				velocity.y = 0
			
			
			if Input.is_action_just_pressed("jump"):
				
				
				
				if current == state.dashing:
					if JUMP_VELOCITY > jumpdefault/4:
						JUMP_VELOCITY = JUMP_VELOCITY/1.5
				else: 
					JUMP_VELOCITY = jumpdefault
				current = state.jumping
				aircurrent = airbornstate.falling
				dashtimer = dtb
				
				
				
			if Input.is_action_pressed("movementkeys") == false:
				
				current = state.idle
			
			
			
			if Input.is_action_just_pressed("swing") && attacktimer.is_stopped():
				attacktimer.start()
				groundedswordbox.monitoring = true
				
			
			if dashtimer > dtb/20:
				if Input.is_action_just_pressed("swing") && aircurrent == airbornstate.grounded:
					current = state.dashattacking
			
		airbornstate.falling:
			if Input.is_action_just_pressed("dash"):
				if airdash:
					current = state.dashing
					airdash= !airdash
			if Input.is_action_just_pressed("jump") && is_on_wall_only():
				JUMP_VELOCITY = jumpdefault
				current = state.jumping
				
			if dashtimer == dtb && Input.is_action_pressed("movementkeys") == false:
				current = state.falling
	
	
	
	
	##print("playerint state: 	"+ str(current))
	##print("airborne:	 " +str(aircurrent))
	move_and_slide()
	
	
	
	
	
	
	
	



func momentconserv(acc: float)-> bool:
	##print("vel:" + str(velocity.x))
	##print("acc:" + str(acc))
	##print(SPEED/1.5)
	if abs(velocity.x + acc) < SPEED || abs(velocity.x + acc) < abs(velocity.x):
		return true
	return false


@onready var bodydetec: Area2D = $bodydetec








func _on_bodydetec_body_entered(body: Node2D) -> void:
	
	if body is TileMapLayer:
		
		var temphold = body.get_used_cells_by_id(0,Vector2i(4,3))
		print(temphold[0])
		
		
		for i in temphold:
			
			body.set_cell(i,-1,Vector2i(-1,-1),-1)
		nextgen.emit()


func _on_attacktimer_timeout() -> void:
	print("pcalled")
	groundedswordbox.monitoring = true

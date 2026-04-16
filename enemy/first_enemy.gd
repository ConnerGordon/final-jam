extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var navigtimer := 10.0

var var_health : float :
	set(new_health):
		var_health = new_health
		if var_health <= 0:
			queue_free()





enum state {idle, wandering,finding}
@export var cur : state = state.idle

var idle_timer := 5.0
var found := false

var playerpos
var uptime := false

var start:= Vector2.ZERO
var end:= Vector2.ZERO

var gravsig = 9.8*2.5

func _ready() -> void:
	var_health = 5
	navigation_agent_2d.link_reached.connect(func(dict:Dictionary):
		
		jump(dict["link_entry_position"],dict["link_exit_position"])
		)

var lerptimer := -1.0
var lerppos
var lerpstart

var postimer := 5.0
var postrack := global_position
var deltglobal := 0



func _physics_process(delta: float) -> void:
	
	
	postimer -= delta*10
	
	
	if not is_on_floor():
		velocity.y += gravsig
		
	
	
	
	if get_tree().get_first_node_in_group("player") != null:
		playerpos = get_tree().get_first_node_in_group("player").global_position
	
	
	
	
	
	
	match cur:
		state.idle:
			if is_on_floor():
				
				velocity = Vector2(0,0)
			else:
				velocity = Vector2(velocity.x,0)
			idle_timer -= delta*10
			if idle_timer <= 0:
				
				
				var target = get_new_target()
				var nav_map = navigation_agent_2d.get_navigation_map()
				
				var safe = NavigationServer2D.map_get_closest_point(nav_map,target)
				
				navigation_agent_2d.target_position = safe#.snapped(Vector2(80,80))
				print(safe.snapped(Vector2(80,80)))
				while safe.distance_to(global_position) < 500 && found == false:
					print("too close")
					nav_map = navigation_agent_2d.get_navigation_map()
					target = NavigationServer2D.map_get_random_point(nav_map,1,true)
					
					safe = NavigationServer2D.map_get_closest_point(nav_map,target)
					
						
						
					
					navigation_agent_2d.target_position = safe#.snapped(Vector2(80,80))
					print(safe.snapped(Vector2(80,80)))
				
				
				
				if found:
					cur = state.finding
				else:
					cur = state.wandering
				if found == false:
					idle_timer = randf_range(2,20)
				else:
					idle_timer = randf_range(1,3)
		
		state.wandering:
			
			var current_pos = global_transform.origin
			var next_position = navigation_agent_2d.get_next_path_position()
			var direc = (next_position - current_pos).normalized()
			if is_on_floor():
				velocity.x = direc.x * SPEED
			if not is_on_floor():
				velocity.x = direc.x *SPEED/10
			
			
			
			
			
			
			if lerptimer >= 0:
				
				global_position = global_position.lerp(lerppos, 1-lerptimer)
				
				lerptimer-= delta/2
				if lerppos.distance_to(global_position) < 50:
					lerptimer = -1
			
			if direc.y < -0.6 && is_on_wall() && is_on_floor():
					velocity.y -= 600
				
			
			#var disto = navigation_agent_2d.get_next_path_position().distance_to(basepos.global_position)
			
			
				
				
				
			#print(navigation_agent_2d.get_next_path_position().distance_to(global_position))
			
			
			
			
			
		state.finding:
			
			var current_pos = global_transform.origin
			var next_position = navigation_agent_2d.get_next_path_position()
			var direc = (next_position - current_pos).normalized()
			if is_on_floor():
				velocity.x = direc.x * SPEED
			if not is_on_floor():
				velocity.x = direc.x *SPEED/10
			
			
			
			
			
			
			if lerptimer >= 0:
				
				global_position = global_position.lerp(lerppos, 1-lerptimer)
				
				lerptimer-= delta/2
				if lerppos.distance_to(global_position) < 50:
					lerptimer = -1
			
			if direc.y < -0.6 && is_on_wall() && is_on_floor():
					velocity.y -= 600
			
			if velocity == Vector2.ZERO:
				navigtimer -= delta
				if navigtimer < 0.0:
					destination_reach()
			
			
			
			
		
	#print(navigation_agent_2d.distance_to_target())
	#print(navigation_agent_2d.target_position)
	#print(navigation_agent_2d.is_target_reached())
	#print(velocity)
	
	
	
	if clampi(velocity.x,-1,1) == -1:
		animated_sprite_2d.flip_h = true
	elif clampi(velocity.x,-1,1) == 1:
		animated_sprite_2d.flip_h = false
	
	
	if postimer < 0.0:
		if postrack == global_position:
			set_idle()
			push_error("nav stuck on wall")
		postrack = global_position
		postimer = 20.0
	move_and_slide()
	
	#print(cur)


func get_new_target():
	var offx = global_position.x
	var offy = global_position.y 
	
	
	if found:
		return playerpos
	
	
	while Vector2(offx,offy).distance_to(global_position) < 500:
		offx = randf_range(-1,1) * 2500
		offy = randi_range(-1,1) * 1000
	
	
	
	
	
	
	
	return global_position + Vector2(offx,offy)
	
	
	
	
	
	
	

func jump(star:Vector2, en:Vector2):
	
	if star.distance_to(global_position) < 100:
		lerppos = en
		lerpstart = star
		lerptimer = 1.0
func set_idle():
	idle_timer = randf_range(2,20)
	cur = state.idle
	


func destination_reach() -> void:
	if is_on_floor():
		set_idle()



func take_damage(playdamage:int):
	var_health -= playdamage



func detected(area: Area2D) -> void:
	print(area.get_parent())
	if area.get_parent() is Player && found == false:
		found = true
		cur = state.idle

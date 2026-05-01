extends CharacterBody2D


const SPEED = 200.0
const JUMP_VELOCITY = -400.0
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@onready var holdingtimer: Timer = $holdingtimer

var navigtimer := 10.0


var var_health : float :
	set(new_health):
		var_health = new_health
		if var_health <= 0:
			queue_free()

@onready var wallscan: RayCast2D = $wallscan




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
	var_health = 100
	navigation_agent_2d.link_reached.connect(func(dict:Dictionary):
		jump(dict["link_entry_position"],dict["link_exit_position"])
		)


var postimer := 5.0
var postrack := global_position
var deltglobal := 0

var pathhold := false
var pathrecall := false
var wallcrawl:= false	
@onready var wallscanback: RayCast2D = $wallscanback

func _physics_process(delta: float) -> void:
	
	
	postimer -= delta*10
	
	
	if not is_on_floor() && wallcrawl == false:
		velocity.y += gravsig
		
	
	
	
	if get_tree().get_first_node_in_group("player") != null:
		playerpos = get_tree().get_first_node_in_group("player").global_position
	
	print(holdingtimer.time_left)
	if is_on_floor():
		if holdingtimer.time_left < holdingtimer.wait_time/2 && holdingtimer.is_stopped() == false:
			holdingtimer.stop()
			holdingtimer.timeout.emit()
	if pathhold == false:
		match cur:
			
			state.idle:
				if is_on_floor():
					
					velocity = Vector2(0,0)
				idle_timer -= delta*10
				if idle_timer <= 0:
					
					if !found:
						
						var nav_map = navigation_agent_2d.get_navigation_map()
						var target = NavigationServer2D.map_get_random_point(nav_map,1,false)
						var safe = NavigationServer2D.map_get_closest_point(nav_map,target)
						if (NavigationServer2D.region_owns_point(nav_map,safe+Vector2(20,0))== false):
								print(safe)
								safe = safe+ (Vector2(-20,0))
								print(safe)
						
						navigation_agent_2d.target_position = (Vector2(int(safe.x) - int(safe.x)%80,int(safe.y)-int(safe.y)%80) + Vector2(40,sign(safe.y)*40))
						print(navigation_agent_2d.target_position)
						
						#while (safe.distance_to(global_position) < 500 && found == false):
							#
							#nav_map = navigation_agent_2d.get_navigation_map()
							#target = NavigationServer2D.map_get_random_point(nav_map,1,false)
							#
							#safe = NavigationServer2D.map_get_closest_point(nav_map,target)
							#
							##print(NavigationServer2D.region_owns_point(nav_map,safe+Vector2(1,0)))
							#if (NavigationServer2D.region_owns_point(nav_map,safe+Vector2(20,0))== false):
								#safe = safe+ (Vector2(-20,0))
							#
							#navigation_agent_2d.target_position = Vector2(int(safe.x) - int(safe.x)%80,int(safe.y)-int(safe.y)%80) + Vector2(40,40)
							#
						while NavigationServer2D.region_owns_point(nav_map,navigation_agent_2d.target_position + Vector2(0,80)):
							navigation_agent_2d.target_position= navigation_agent_2d.target_position +Vector2(0,80)
					else:
						
						
						
						var nav_map = navigation_agent_2d.get_navigation_map()
						var target = NavigationServer2D.map_get_closest_point(nav_map,playerpos)
						if (NavigationServer2D.region_owns_point(nav_map,target+Vector2(20,0))== false):
								target = target+ (Vector2(-20,0))
						var safe = Vector2(int(target.x) - int(target.x)%80,int(target.y)-int(target.y)%80) + Vector2(40,40)
						
						
						navigation_agent_2d.target_position =safe
						
							
					
					print(navigation_agent_2d.target_position)
					if found:
						cur = state.finding
					else:
						cur = state.wandering
						idle_timer = randf_range(2,20)

			
			state.wandering:
				if is_on_floor():
					navigation_agent_2d.target_position = navigation_agent_2d.target_position
				
				var current_pos = global_transform.origin
				var next_position = navigation_agent_2d.get_next_path_position()
				
				var direc = (next_position - current_pos).normalized()
				if is_on_floor():
					
					if pathrecall:
						#print("calledquerey")
						
						
						pathrecall = false
					
					if abs(velocity.x + direc.x * SPEED) < SPEED*1.5:
						velocity.x += direc.x * SPEED
					else:
						velocity.x = sign(direc.x) * SPEED * 1.5
					if wallscan.is_colliding() || wallscanback.is_colliding():
						wallcrawl= true
						
						if direc.y < -0.66:
							velocity.y = -300
					
					
				if not is_on_floor():
					if abs(velocity.x + direc.x * SPEED*2/10) < SPEED/2:
						velocity.x += direc.x *SPEED*2/10
					
				
				
				if navigation_agent_2d.is_target_reachable() != true:
					pass
					#set_idle()
				
				
				
				#
				
				#var disto = navigation_agent_2d.get_next_path_position().distance_to(basepos.global_position)
				
				
					
					
					
				#print(navigation_agent_2d.get_next_path_position().distance_to(global_position))
				
				
				
				
				
			state.finding:
				var target = playerpos
				var nav_map = navigation_agent_2d.get_navigation_map()
				
				var safe = NavigationServer2D.map_get_closest_point(nav_map,target)
				navigation_agent_2d.target_position = safe
				var current_pos = global_transform.origin
				var next_position = navigation_agent_2d.get_next_path_position()
				var direc = (next_position - current_pos).normalized()
				if is_on_floor():
					if abs(velocity.x + direc.x * SPEED) < SPEED * 2:
						
						velocity.x += direc.x * SPEED
					else:
						velocity.x = sign(direc.x) * SPEED * 2
						
					if wallscan.is_colliding() || wallscanback.is_colliding():
						wallcrawl = true
						if direc.y < -0.66:
							velocity.y = -500
							
				if not is_on_floor():
					if abs(velocity.x + direc.x * SPEED*2/10) < SPEED/2:
						velocity.x += direc.x *SPEED*2/10
					#print(navigation_agent_2d.get_next_path_position().distance_to(global_position))
					
					
					
					
					
				#if not is_on_floor():
					#if abs(velocity.x + direc.x * SPEED*2/10) < SPEED/2:
					#	velocity.x += direc.x *SPEED*2/10
				
				
				
				
				
				
				
				
			
		
		
		
		
		if clampi(velocity.x,-1,1) == -1:
			animated_sprite_2d.flip_h = true
		elif clampi(velocity.x,-1,1) == 1:
			animated_sprite_2d.flip_h = false
		
		
		if postimer < 0.0:
			if postrack == navigation_agent_2d.get_next_path_position():
				set_idle()
				push_error("nav stuck on wall")
			postrack = navigation_agent_2d.get_next_path_position()
			postimer = 40.0
			if found:
				postimer = 20.0
		move_and_slide()
	
	if wallscan.is_colliding() == false && wallscanback.is_colliding() == false:
		wallcrawl = false


func jump(star:Vector2, en:Vector2):
	
	if pathhold == false && global_position.distance_to(star) < 50 && holdingtimer.is_stopped():
		
		pathhold = true
		if star.y > en.y:
			#print("UP  on navigationlink")
			global_position = star
			
			var postween := create_tween()
			postween.tween_property(self, "global_position",Vector2.UP * (star.y-en.y),(en.distance_to(star))/1000).as_relative()
			await postween.finished
			var postweenx := create_tween()
			postweenx.tween_property(self, "global_position",en,.25)
			pathhold = false
		elif star.y < en.y :
			#print("Down  on navigationlink")
			var startween = create_tween()
			startween.tween_property(self, "global_position",star,.2)
			
			await startween.finished
			#var postweenx := create_tween()
			#postweenx.tween_property(self, "position",Vector2.RIGHT* sign(en.x-star.x)*80,.3).as_relative()
			#await postweenx.finished
			velocity.x = 400 *sign(en.x - star.x)
			velocity.y -= 400
			holdingtimer.start()
			pathrecall = true
		else:
			var postweenx = create_tween()
			postweenx.tween_property(self, "position",Vector2.RIGHT* (en.x-star.x),.3).as_relative()
			await postweenx.finished
			pathhold = false
			pathrecall = true
		
func set_idle():
	cur = state.idle
	


func destination_reach() -> void:
	#print("reach")
	set_idle()
	if !found: 
		idle_timer= randf_range(2,20)



func take_damage(playdamage:int):
	var_health -= playdamage



func detected(area: Area2D) -> void:
	
	if area.get_parent() is Player && found == false:
		found = true
		cur = state.finding
		


func _on_navigation_agent_2d_path_changed() -> void:
		#print("calledpathchange")
		pass


func _on_navigation_agent_2d_waypoint_reached(details: Dictionary) -> void:
	#print(details["position"])
	#print(details["type"])
	#print(navigation_agent_2d.distance_to_target())
	pass


func _on_holdingtimer_timeout() -> void:
	#print("time") 
	pathhold = false

extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var basepos: Marker2D = $basepos

var navigtimer := 10.0

var var_health : float :
	set(new_health):
		var_health = new_health
		if var_health <= 0:
			queue_free()





enum state {idle, wandering,finding}
var cur : state = state.idle

var idle_timer := 5.0
var found := false

var playerpos
var uptime := false

var start:= Vector2.ZERO
var end:= Vector2.ZERO

func _ready() -> void:
	var_health = 5
	navigation_agent_2d.link_reached.connect(jump)




func _physics_process(delta: float) -> void:
	
	
	
	
	if not is_on_floor():
		velocity.y += 9.8 * 2.5
		
	
	
	
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
				
				while navigation_agent_2d.is_target_reachable() != true:
					print("recal")
					target = get_new_target()
					nav_map = navigation_agent_2d.get_navigation_map()
					safe = NavigationServer2D.map_get_closest_point(nav_map,target)
					
				navigation_agent_2d.target_position = safe
				
				
				
				if found:
					cur = state.finding
				else:
					cur = state.wandering
				idle_timer = randf_range(2,20)
		
		state.wandering:
			var current_pos = global_transform.origin
			var next_position = navigation_agent_2d.get_next_path_position()
			var direc = (next_position - current_pos).normalized()
			if is_on_floor():
				velocity.x = direc.x * SPEED
			
			
			#var disto = navigation_agent_2d.get_next_path_position().distance_to(basepos.global_position)
			
			if uptime && start.y < end.y:
				velocity.y -= abs(start.y-end.y*9.8*5/delta)
				
				
				
			print(navigation_agent_2d.get_next_path_position().distance_to(global_position))
			
			
			print(velocity.round())
			if velocity.round() == Vector2.ZERO:
				navigtimer -= delta * 10
				if navigtimer < 0.0:
					destination_reach()
					navigtimer = 10.0
			
			
			
		state.finding:
			var current_pos = global_transform.origin
			var next_position = navigation_agent_2d.get_next_path_position()
			var direc = (next_position - current_pos).normalized()
			velocity.x = direc.x * SPEED
			
			if velocity == Vector2.ZERO:
				navigtimer -= delta
				if navigtimer < 0.0:
					destination_reach()
			
			
			
			
		
	#print(navigation_agent_2d.distance_to_target())
	#print(navigation_agent_2d.target_position)
	#print(navigation_agent_2d.is_target_reached())
	#print(velocity)
	
	move_and_slide()
	
	print(cur)


func get_new_target():
	
	var offx = randf_range(-2500,2500)
	var offy = randf_range(-500,500)
	
	if found:
		return playerpos
	
	return global_position + Vector2(offx,offy)
	
	
	
	
	
	
	

func jump(star:Vector2, en:Vector2):
	uptime = true
	start = star
	end = en
func set_idle():
	idle_timer = randf_range(2,20)
	cur = state.idle
	


func destination_reach() -> void:
	set_idle()



func take_damage(playdamage:int):
	var_health -= playdamage



func detected(area: Area2D) -> void:
	if area.get_parent() is Player:
		found = true

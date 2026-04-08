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

var targetpoint := Vector2(0.0,0.0)
func _ready() -> void:
	var_health = 5
func _physics_process(delta: float) -> void:
	
	
	
	
	if not is_on_floor():
		velocity.y += 9.8 * 2.5
		
	
	
	
	if get_tree().get_first_node_in_group("player") != null:
		playerpos = get_tree().get_first_node_in_group("player").global_position
	
	
	
	match cur:
		state.idle:
			velocity = Vector2(velocity.x,0)
			idle_timer -= delta*10
			if idle_timer <= 0:
				
				
				var target = get_new_target()
				var nav_map = navigation_agent_2d.get_navigation_map()
				var safe = NavigationServer2D.map_get_closest_point(nav_map,target)
				
				while navigation_agent_2d.is_target_reachable() != true:
					target = get_new_target()
					nav_map = navigation_agent_2d.get_navigation_map()
					safe = NavigationServer2D.map_get_closest_point(nav_map,target)
					
				navigation_agent_2d.target_position = safe
				
				targetpoint = safe
				
				if found:
					cur = state.finding
				else:
					cur = state.wandering
				idle_timer =5.0
		
		state.wandering:
			var current_pos = global_transform.origin
			var next_position = navigation_agent_2d.get_next_path_position()
			var direc = (next_position - current_pos).normalized()
			if is_on_floor():
				velocity.x = direc.x * SPEED
			
			
			var disto = navigation_agent_2d.get_next_path_position().distance_to(basepos.global_position)
			
			if direc.y <= -.899999 && is_on_floor() && disto > 500:
				velocity.y -= abs(sin(disto)*9.8*5/delta)
				
				print(disto)
				
			
			
			
			
			if velocity == Vector2.ZERO:
				navigtimer -= delta
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
			
			
			
			
		
	print(navigation_agent_2d.distance_to_target())
	print(navigation_agent_2d.target_position)
	print(navigation_agent_2d.is_target_reached())
	move_and_slide()
	


func get_new_target():
	
	var offx = randf_range(-2500,2500)
	var offy = randf_range(-1000,-500)
	
	if found:
		return playerpos
	
	return global_position + Vector2(offx,offy)
	
	
	
	
	
	
	


func set_idle():
	idle_timer = randf_range(2,20)
	cur = state.idle
	


func destination_reach() -> void:
	cur = state.idle



func take_damage(playdamage:int):
	var_health -= playdamage



func detected(area: Area2D) -> void:
	if area.get_parent() is Player:
		found = true

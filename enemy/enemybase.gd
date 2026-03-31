extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D

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


func _ready() -> void:
	var_health = 5
func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity.y += 9.8 * delta * 2.5
	
	
	
	if get_tree().get_first_node_in_group("player") != null:
		var playerpos = get_tree().get_first_node_in_group("player").global_position
	
	
	
	match cur:
		state.idle:
			velocity = Vector2.ZERO
			idle_timer -= delta*50
			
			if idle_timer <= 0:
				var target = get_new_target()
				var nav_map = navigation_agent_2d.get_navigation_map()
				var safe = NavigationServer2D.map_get_closest_point(nav_map,target)
				navigation_agent_2d.target_position = safe
				
				if found:
					cur = state.finding
				else:
					cur = state.wandering
				idle_timer =5.0
		
		state.wandering:
			var current_pos = global_transform.origin
			var next_position = navigation_agent_2d.get_next_path_position()
			var direc = (next_position - current_pos).normalized()
			velocity = direc * SPEED
			if velocity == Vector2.ZERO:
				navigtimer -= delta
				if navigtimer < 0.0:
					
					destination_reach()
					navigtimer = 10.0
				
			
			
			
			
			
			
			
			
			
			
	move_and_slide()
	


func get_new_target():
	
	var offx = randf_range(-15,15)
	var offy = randf_range(-15,15)
	
	
	
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

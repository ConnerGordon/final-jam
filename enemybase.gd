extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D



enum state {idle, wandering,finding}
var cur : state = state.idle

var idle_timer := 5.0



func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	
	match cur:
		state.idle:
			velocity = Vector2.ZERO
			idle_timer -= delta*50
			
			if idle_timer <= 0:
				var target = get_new_target()
				var nav_map = navigation_agent_2d.get_navigation_map()
				var safe = NavigationServer3D.map_get_closest_point(nav_map,target)
				navigation_agent_2d.target_position = safe
				if found:
					state = State.PLAYERTARG
				else:
					state = State.MOVE
		
		
			
	
	


func get_new_target():
	
	var offx = randf_range(-15,15)
	var offy = randf_range(-15,15)
	
	
	
	return global_position + Vector2(offx,offy)
	
	
	
	
	
	

	move_and_slide()


func set_idle():
	idle_timer = randf_range(2,20)
	cur = state.idle
	

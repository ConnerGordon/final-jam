extends Node


@onready var g = preload("res://enemy/husk.tscn")


var Totalpoints = 1#randi_range(7,10)

var basicpoints = 5


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#get_tree().get_first_node_in_group("enemyholder")!= null
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func callspawn(calledmap:TileMapLayer):
	for i in range(Totalpoints):
		var spawn = g.instantiate()
		get_tree().get_first_node_in_group("enemyholder").add_child(spawn)
		var rand_empty = calledmap.get_used_cells_by_id(-1,Vector2i(6,5),-1).pick_random()
		spawn.global_position = calledmap.to_global(calledmap.map_to_local(rand_empty))
		calledmap.set_cell(rand_empty,0,Vector2i(5,5))
		
		

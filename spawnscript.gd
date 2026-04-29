extends GridMap


@onready var g = preload("res://enemy/husk.tscn")


var Totalpoints = randi_range(20,30)

var basicpoints = 5


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	for i in range(Totalpoints):
		var spawn = g.instantiate()
		get_tree().get_first_node_in_group("enemyholder").add_child(spawn)
		var rand_empty = get_used_cells_by_item(0).pick_random()
		spawn.global_position = to_global(map_to_local(rand_empty))
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

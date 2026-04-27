extends Node2D

@onready var nextmappoint: Marker2D = $nextmappoint
@onready var character_body_2d: CharacterBody2D = $CharacterBody2D


var basehall1 : PackedScene = preload("res://folder base/basehall1.tscn")
var fighthall1 : PackedScene = preload("res://folder base/fightinghall1.tscn")
var uppath: PackedScene = preload("res://folder base/upwardpath.tscn")
var downpath: PackedScene = preload("res://folder base/downpath.tscn")

var roomarray : Array[PackedScene] = [fighthall1,uppath,downpath]
@onready var enemyholder: Node2D = $enemyholder



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	character_body_2d.nextgen.connect(spawnroom)
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		spawnroom()
		
		




func spawnroom()->void:
	var preloadscene = roomarray[randf_range(0,3)]
	var loaded = preloadscene.instantiate()
	add_child(loaded)
	loaded.global_position = nextmappoint.global_position
	nextmappoint.global_position = loaded.get_child(0).global_position

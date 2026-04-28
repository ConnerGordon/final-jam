extends Node2D

@onready var nextmappoint: Marker2D = $nextmappoint
@onready var character_body_2d: CharacterBody2D = $CharacterBody2D
@onready var mapholder: Node2D = $mapholder


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
		pass
		
		


func intake(pos:Vector2,type:Variant,health:int):
	pass


func spawnroom()->void:
	var preloadscene = roomarray[randf_range(0,3)]
	var loaded = preloadscene.instantiate()
	mapholder.add_child(loaded)
	loaded.global_position = nextmappoint.global_position
	nextmappoint.global_position = loaded.get_child(0).global_position

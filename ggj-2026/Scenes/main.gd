extends Node
var level1 = preload("res://Scenes/level_1.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global.main = self
	global.level = $level1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func load_level(nextLevel):
	global.level.queue_free()
	var levelInstance = nextLevel.instantiate()
	add_child(levelInstance)
	global.level = levelInstance

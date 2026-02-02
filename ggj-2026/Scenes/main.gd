extends Node
#var level1 = preload("res://Scenes/level_1.tscn")
#var level2 = preload("res://Scenes/level_2.tscn")
var levelA = preload("res://Scenes/level_A.tscn")

var levelC = preload("res://Scenes/level_C.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global.main = self
	global.level = $level_A #$level_2



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func load_level(nextLevel):
	if global.level:
		global.level.queue_free()
	global.currentLevel = nextLevel
	var levelInstance = nextLevel.instantiate()
	add_child(levelInstance)
	global.level = levelInstance

func deathSound():
	if $deathSound.playing == false:
		$deathSound.play()

extends Area2D
@export var nextLevel = preload("res://Scenes/level_1.tscn")

# Called when the node enters the scene tree for the first dtime.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_entered(area: Area2D) -> void:
	print(area.get_groups())
	if area.is_in_group("playerHitbox"):
		global.main.load_level(nextLevel)

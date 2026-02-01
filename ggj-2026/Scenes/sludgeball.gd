extends RigidBody2D

@onready var despawnTimer = $sludgeDespawn

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	despawnTimer.start(1)
	


func _on_sludge_despawn_timeout() -> void:
	queue_free()


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		area.owner.queue_free()
		queue_free()

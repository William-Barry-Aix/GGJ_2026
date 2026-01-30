extends Area2D
class_name Portal

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	

#This function will handle transition to the portal towards the next level (things to define)
func _on_body_entered(body: Node) -> void:
	if body is Player:
		pass
	pass

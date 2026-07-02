extends Node2D


func _ready() -> void:
	EffectAnimation2D.spawn(Vector2(100, 200), self, "test/asset/explosion_animation.png", 0.5)
	pass

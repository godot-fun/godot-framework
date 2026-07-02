extends Node2D


func _ready() -> void:
	EffectAnimation2D.spawn(Vector2(100, 200), self, "test/asset/explosion_animation.png", Vector2i(8, 1), 0.5)
	EffectAnimation2D.spawn(Vector2(500, 200), self, "test/asset/character_attack.png", Vector2i(4, 4), 0.5, 13)
	pass

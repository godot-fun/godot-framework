extends Node

func _ready() -> void:
	Alert_test()
	pass


func Alert_test() -> void:
	Alert.alert("Test", Colors.success)
	pass

# --------------------------------------------------------------------------------------------------
class StudentSimple:
	var name: String
	var age: int
pass


func simple_json_test() -> void:
	var json := "{\"name\": \"test\", \"age\": 10}"
	var obj = JsonUtils.json_to_object(json, StudentSimple)
	var json_text := JsonUtils.object_to_json(obj)
	assert(json == json_text)
	pass



# --------------------------------------------------------------------------------------------------
class Student:
	var name: String
	var age: int
	var subjects: Array[String]
	
pass


func json_test() -> void:
	var student := Student.new()
	student.name = "Peter"
	student.age = 30
	student.subjects = ["math", "history"]
	var json := JsonUtils.object_to_json(student)
	var obj: Student = JsonUtils.json_to_object(json, Student)
	var json_text := JsonUtils.object_to_json(obj)
	assert(json == json_text)
	pass
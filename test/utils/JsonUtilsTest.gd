# --------------------------------------------------------------------------------------------------
class Teacher:
	var name: String
	var age: int
	pass

static var teacher1 := Teacher.new()
static var teacher2 := Teacher.new()

static func test_before() -> void:
	teacher1.name = "Peter"
	teacher1.age = 50
	teacher2.name = "David"
	teacher2.age = 40
	pass

func simple_json_test() -> void:
	var json := "{\"name\": \"test\", \"age\": 10}"
	var obj = JsonUtils.json_to_object(json, Teacher)
	var json_text := JsonUtils.object_to_json(obj)
	assert(json == json_text)
	pass



# --------------------------------------------------------------------------------------------------
class Student:
	var name: String
	var age: int
	var subjects: Array[String]
	var teachers: Array[Teacher]
	var scores: Dictionary[String, int]
	var teacherMap: Dictionary[String, Teacher]
pass


func json_test() -> void:
	var student := Student.new()
	student.name = "Peter"
	student.age = 30
	student.subjects = ["math", "history"]
	student.teachers = [teacher1, teacher1]
	student.scores = {}
	student.scores["math"] = 100
	student.scores["history"] = 99
	student.teacherMap = {}
	student.teacherMap["Peter"] = teacher1
	student.teacherMap["David"] = teacher2
	var json := JsonUtils.object_to_json(student)
	var obj: Student = JsonUtils.json_to_object(json, Student)
	var json_text := JsonUtils.object_to_json(obj)
	assert(json == json_text)
	pass
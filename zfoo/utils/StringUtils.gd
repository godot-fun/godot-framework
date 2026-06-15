class_name StringUtils
extends Object

const EMPTY: String = ""
const EMPTY_JSON: String = "{}"
const SPACE: String = " "
const COMMA: String = ","
const LS: String = "\n"

# Checks if a String is empty ("") or null
static func is_empty(s: String) -> bool:
	return s == null or s.length() == 0

static func is_not_empty(s: String) -> bool:
	return !is_empty(s)

static func is_blank(s: String) -> bool:
	if is_empty(s):
		return true
	
	if is_empty(s.strip_edges(true, true)):
		return true
		
	return false

static func is_not_blank(s: String) -> bool:
	return !is_blank(s)

static func format(template: String, ...args: Array) -> String:
	if is_empty(template):
		return template
	if (ArrayUtils.is_empty(args)):
		return template
	return template.format(args, EMPTY_JSON)

static func substring_before(s: String, delimiter: String) -> String:
	if is_empty(s):
		return EMPTY
	var index := s.find(delimiter)
	if index == -1:
		return EMPTY
	return s.substr(0, index)

static func substring_after(s: String, delimiter: String) -> String:
	if is_empty(s):
		return EMPTY
	var index := s.find(delimiter)
	if index == -1:
		return EMPTY
	return s.substr(index + delimiter.length(), s.length())


static func enum_to_string(enum_obj: Dictionary, value: int) -> String:
	for key in enum_obj.keys():
		if enum_obj[key] == value:
			return key
	return "UNKNOWN"

# ----------------------------------------------------------------------------------------------------------------------
const ANIMAL_EMOJIS: PackedStringArray = [
	"🐶","🐱","🐭","🐹","🐰","🦊","🐻","🐼","🐻‍","🐨","🐯","🦁","🐮","🐷","🐽","🐸","🐵","🙈","🙉","🙊",
	"🐒","🐔","🐧","🐦","🐤","🐣","🐥","🦆","🦅","🦉","🦇","🐺","🐗","🐴","🦄","🐝","🐛","🦋","🐌","🐞",
	"🕷️","🦂","🦟","🦀","🦞","🦐","🦑","🐙","🐡","🐠","🐟","🐬","🐳","🐋","🦈","🐊","🐅","🐆","🦓","🦍",
	"🦧","🐘","🦛","🦏","🐪","🐫","🦒","🦘","🐃","🐂","🐄","🐎","🐖","🐏","🐑","🦙","🐐","🦌","🐕","🐩",
	"🦮","🐕‍🦺","🐈","🐓","🦃","🦚","🦜","🦢","🦩","🕊️","🐇","🦝","🦨","🦡","🦦","🦥","🐁","🐀","🐿️","🦔",
	"🐉","🐲"]

# random emoji
static func random_emoji() -> String:
	# emoji Unicode range
	var ranges := [
		[0x1F600, 0x1F64F], # emoj
		[0x1F300, 0x1F5FF], # other
		[0x1F680, 0x1F6FF], # traffic
		[0x1F900, 0x1F9FF], # emoj
	]

	var r = ranges.pick_random()

	var codepoint := randi_range(r[0], r[1])

	var emoji := char(codepoint)

	if StringUtils.is_blank(emoji):
		return emoji
	
	return RandomUtils.random_ele(ANIMAL_EMOJIS)
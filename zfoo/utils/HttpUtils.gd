class_name HttpUtils
extends Object

static func is_https_url(url: String) -> bool:
	if StringUtils.is_blank(url):
		return false
	return url.strip_edges().begins_with("https://")

static func is_valid_http_url(url: String) -> bool:
	return url.begins_with("http://") || url.begins_with("https://")

# https://www.google.com -> www.google.com
static func get_host_from_url(url: String) -> String:
	var no_protocol := _remove_protocol(url)
	var slash_index := no_protocol.find("/")
	if slash_index != -1:
		no_protocol = no_protocol.substr(0, slash_index)

	var colon_index := no_protocol.find(":")
	if colon_index != -1:
		return no_protocol.substr(0, colon_index)

	return no_protocol


# https://www.google.com -> 443
# http://localhost:8080 -> 8080
static func get_port_from_url(url: String) -> int:
	var no_protocol := _remove_protocol(url)
	var slash_index := no_protocol.find("/")
	if slash_index != -1:
		no_protocol = no_protocol.substr(0, slash_index)

	var colon_index := no_protocol.find(":")
	if colon_index != -1:
		return int(no_protocol.substr(colon_index + 1))

	if is_https_url(url):
		return 443
	return 80


# https://www.google.com/search -> /search
static func get_path_from_url(url: String) -> String:
	var no_protocol := _remove_protocol(url)
	var slash_index := no_protocol.find("/")
	if slash_index != -1:
		return no_protocol.substr(slash_index)
	return "/"


static func _remove_protocol(url: String) -> String:
	if url.begins_with("http://"):
		return url.substr(7)
	elif url.begins_with("https://"):
		return url.substr(8)
	return url

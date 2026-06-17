class_name AsyncHttp
extends IComponent

const DEFAULT_TIMEOUT_MILLIS: int = 60 * TimeUtils.MILLIS_PER_SECOND

# SignalBridge
var signalTasks: Array[HttpTask] = []

func _init() -> void:
	start()
	pass

# IComponent-Interface-Implement-Start
func start() -> void:
	super.start()
	pass

func update() -> void:
	if signalTasks.is_empty():
		return
	var finishedTasks: Array[HttpTask] = []
	for task in signalTasks:
		_poll_task(task)
		if task.done:
			finishedTasks.append(task)
	if finishedTasks.is_empty():
		return
	for task in finishedTasks:
		# task.emit_signal("http_signal", task.response)
		task.http_signal.emit(task.response)
	finishedTasks.clear()
	pass
# IComponent-Interface-Implement-End

func _poll_task(task: HttpTask) -> void:
	var client := task.client
	client.poll()
	
	var now := TimeUtils.current_time_millis()
	if (now - task.startTime) > DEFAULT_TIMEOUT_MILLIS:
		fail(task)
		Log.error("HTTP Request timeout url:[{}]", task.url)
		return
	
	var status := client.get_status()
	var response := task.response
	match status:
		HTTPClient.STATUS_CANT_RESOLVE:
			fail(task)
			Log.error("Http resolve error:[STATUS_CANT_RESOLVE] url:[{}]", task.url)
		HTTPClient.STATUS_CANT_CONNECT:
			fail(task)
			Log.error("Http connect error:[STATUS_CANT_CONNECT] url:[{}]", task.url)
		HTTPClient.STATUS_TLS_HANDSHAKE_ERROR:
			fail(task)
			Log.error("Http tls error:[STATUS_TLS_HANDSHAKE_ERROR] url:[{}]", task.url)
		HTTPClient.STATUS_DISCONNECTED:
			fail(task)
			Log.error("Http connection error:[STATUS_DISCONNECTED] url:[{}]", task.url)
		HTTPClient.STATUS_CONNECTION_ERROR:
			fail(task)
			Log.error("Http connection error:[STATUS_CONNECTION_ERROR] url:[{}]", task.url)
		HTTPClient.STATUS_REQUESTING, HTTPClient.STATUS_RESOLVING, HTTPClient.STATUS_CONNECTING:
			pass
		HTTPClient.STATUS_CONNECTED:
			var err := client.request(task.method, HttpUtils.get_path_from_url(task.url), task.headers, task.body)
			if err != OK:
				fail(task)
				Log.error("Http request error url:[{}]", task.url)
		HTTPClient.STATUS_BODY:
			if client.has_response():
				var chunk := client.read_response_body_chunk()
				# prefer using the length.
				if client.get_response_body_length() > 0:
					response.body.append_array(chunk)
					if response.body.size() >= client.get_response_body_length():
						complete(task)
				else:
					# HTTP **chunked(Transfer-Encoding: chunked)** end flag is a chunk with lenth 0
					if client.is_response_chunked():
						if StringUtils.is_empty(chunk.get_string_from_utf8()):
							complete(task)
						else:
							response.body.append_array(chunk)
					else:
						response.body.append_array(chunk)
						complete(task)
		pass

func fail(task: HttpTask) -> void:
	var client := task.client
	task.done = true
	client.close()
	pass

func complete(task: HttpTask) -> void:
	var client := task.client
	var response := task.response
	# read complete
	response.code = client.get_response_code()
	response.headers = client.get_response_headers_as_dictionary()
	response.success = true
	task.done = true
	client.close()
	Log.info("HTTP request successful url:[{}] code:[{}] body length:[{}]", task.url, response.code, response.body.size())
	pass


####################################################################################################
func async_request(method: HTTPClient.Method, url: String, headers: PackedStringArray = PackedStringArray(), body: String = "") -> HttpResponse:
	if !HttpUtils.is_valid_http_url(url):
		Log.error("Http is not valid http url:[{}]", url)
		return HttpResponse.new()
	var host := HttpUtils.get_host_from_url(url)
	var port := HttpUtils.get_port_from_url(url)
	Log.info("Http request url:[{}]", url)
	var client := HTTPClient.new()
	
	var err := client.connect_to_host(host, port, TLSOptions.client()) if HttpUtils.is_https_url(url) else client.connect_to_host(host, port)
	if err != OK:
		Log.error("Http connect error:[{}]", err)
		return HttpResponse.new()

	var signalId := IdUtils.local_id()
	var task: HttpTask = HttpTask.new(signalId, client, method, url, headers, body)
	signalTasks.append(task)
	var response: HttpResponse = await task.http_signal
	var index := signalTasks.find(task)
	signalTasks.remove_at(index)
	return response


####################################################################################################
class HttpTask:
	signal http_signal(response: HttpResponse)

	var signalId: int
	var client: HTTPClient
	var method: HTTPClient.Method
	var url: String
	var headers: PackedStringArray
	var body: String
	var startTime: int
	var response: HttpResponse = HttpResponse.new()
	var done: bool = false

	func _init(_signalId: int, _client: HTTPClient, _method: HTTPClient.Method, _url: String, _headers: PackedStringArray, _body: String):
		self.signalId = _signalId
		self.client = _client
		self.method = _method
		self.url = _url
		self.headers = _headers
		self.body = _body
		self.startTime = TimeUtils.current_time_millis()
		pass

class_name ResourceHelper
extends Object

static var loader: AsyncResourceLoader = AsyncResourceLoader.new()

static func async_load(path: String) -> Resource:
	return await loader.async_load(path)

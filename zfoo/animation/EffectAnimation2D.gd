extends AnimatedSprite2D
class_name EffectAnimation2D

const ANIMATION_NAME := "default"

var animation_resource: String
var frame_size: Vector2i
var frame_count: int
var animation_fps: float
var scale_ratio: float


func _ready() -> void:
	z_index = 1024

	scale = Vector2.ONE * scale_ratio
	setup_sprite_frames()
	animation_finished.connect(on_animation_finished)
	play(ANIMATION_NAME)
	pass


func setup_sprite_frames() -> void:
	var sheet: Texture2D = load(animation_resource)
	var frames := SpriteFrames.new()
	if not frames.has_animation(ANIMATION_NAME):
		frames.add_animation(ANIMATION_NAME)
	frames.set_animation_speed(ANIMATION_NAME, animation_fps)
	frames.set_animation_loop(ANIMATION_NAME, false)

	for i in frame_count:
		var atlas := AtlasTexture.new()
		atlas.atlas = sheet
		atlas.region = Rect2(i * frame_size.x, 0, frame_size.x, frame_size.y)
		frames.add_frame(ANIMATION_NAME, atlas)

	sprite_frames = frames
	pass



func on_animation_finished() -> void:
	queue_free()
	pass


static func spawn(
	pos: Vector2,
	parent: Node,
	_animation_resource: String,
	_scale_ratio: float = 1,
	_frame_count: int = 8,
	_frame_size: Vector2i = Vector2i(256, 256),
	_animation_fps: float = 14.0
) -> void:
	var effect := EffectAnimation2D.new()
	effect.animation_resource = _animation_resource
	effect.frame_size = _frame_size
	effect.frame_count = _frame_count
	effect.animation_fps = _animation_fps
	effect.scale_ratio = _scale_ratio
	effect.global_position = pos
	parent.add_child(effect)
	pass

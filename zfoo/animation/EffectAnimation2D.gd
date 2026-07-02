extends AnimatedSprite2D
## One-shot 2D sprite sheet effect. Plays once and queue_free() when finished.
class_name EffectAnimation2D

const ANIMATION_NAME := "default"

var animation_resource: String
## Sprite sheet layout: x = columns, y = rows.
var frame_grid: Vector2i
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
	var animation_texture: Texture2D = load(animation_resource)
	# Derive frame size from sheet dimensions and grid layout.
	var frame_size := Vector2i(animation_texture.get_width() / frame_grid.x, animation_texture.get_height() / frame_grid.y)
	var frames := SpriteFrames.new()
	if not frames.has_animation(ANIMATION_NAME):
		frames.add_animation(ANIMATION_NAME)
	frames.set_animation_speed(ANIMATION_NAME, animation_fps)
	frames.set_animation_loop(ANIMATION_NAME, false)

	for row in frame_grid.y:
		for col in frame_grid.x:
			# Read frames left-to-right, top-to-bottom.
			var atlas := AtlasTexture.new()
			atlas.atlas = animation_texture
			atlas.region = Rect2(col * frame_size.x, row * frame_size.y, frame_size.x, frame_size.y)
			frames.add_frame(ANIMATION_NAME, atlas)

	sprite_frames = frames
	pass



func on_animation_finished() -> void:
	queue_free()
	pass


## Spawn and play a sprite sheet effect at `pos` under `parent`.
static func spawn(
	pos: Vector2,
	parent: Node,
	_animation_resource: String,
	_frame_grid: Vector2i = Vector2i(8, 1),
	_scale_ratio: float = 1,
	_animation_fps: float = 14.0
) -> void:
	var effect := EffectAnimation2D.new()
	effect.animation_resource = _animation_resource
	effect.frame_grid = _frame_grid
	effect.animation_fps = _animation_fps
	effect.scale_ratio = _scale_ratio
	effect.global_position = pos
	parent.add_child(effect)
	pass

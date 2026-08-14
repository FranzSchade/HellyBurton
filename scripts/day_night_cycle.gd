extends CanvasModulate

@export var gradient:GradientTexture1D
@export var ingame_speed = 1.0
@export var initial_hour = 12

const MINUTES_PER_DAY = 1440
const MINUTES_PER_HOUR = 60
const INGAME_TO_REAL_MINUTE_DURATION = (2 * PI) / MINUTES_PER_DAY

signal time_tick(day:int, hour:int, minute:int)

var time = 0

func _ready():
	time = INGAME_TO_REAL_MINUTE_DURATION * initial_hour * MINUTES_PER_HOUR
	_update_color()

func _process(delta:float) -> void:
	time += delta * INGAME_TO_REAL_MINUTE_DURATION * ingame_speed
	_update_color()

func _set_time(h):
	time = INGAME_TO_REAL_MINUTE_DURATION * h * MINUTES_PER_HOUR
	_update_color()

func _update_color() -> void:
	var value = (sin(time - PI / 2) + 1.0) / 2.0
	self.color = gradient.gradient.sample(value)

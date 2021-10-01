extends Panel

onready var offsetMoveTimer :Timer = get_parent().get_parent().get_node("OffsetMoveTimer")
onready var marchingSquare = get_parent().get_parent()
var offsetMoveTimerIsRunning :bool = true

func _ready():
	offsetMoveTimer.start()

func incrementNoiseOffset() -> void:
	marchingSquare.noiseOffsetVector += Vector2(1, 1)
	
func _on_OffsetMoveTimer_timeout() -> void:
	incrementNoiseOffset()
	marchingSquare.updateValues()

func _on_SpeedSlider_value_changed(value) -> void:
	offsetMoveTimer.wait_time = clamp(value, 0, 1)
	
	if (offsetMoveTimerIsRunning):
		offsetMoveTimer.start()

func _on_AnimateCheckButton_toggled(button_pressed) -> void:
	offsetMoveTimerIsRunning = button_pressed
	if (offsetMoveTimerIsRunning):
		offsetMoveTimer.start()
	else:
		offsetMoveTimer.stop()

func _on_SizeXSlider_value_changed(value) -> void:
	marchingSquare.sizeX = int(clamp(value, 4, 200))

func _on_SizeYSlider_value_changed(value) -> void:
	marchingSquare.sizeY = int(clamp(value, 4, 200))

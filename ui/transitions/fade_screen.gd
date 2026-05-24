extends CanvasLayer

@onready var rect: ColorRect = $ColorRect

func fade_out() -> void:
	var tween = create_tween()
	tween.tween_property(rect, "modulate:a", 1.0, 0.6)
	await tween.finished

func fade_in() -> void:
	var tween = create_tween()
	tween.tween_property(rect, "modulate:a", 0.0, 0.6)
	await tween.finished

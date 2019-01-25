extends Particles2D

export (float) var duration = 0.8

var color = self.modulate

func _ready():
	emitting = true
	color.a = 0
	$Tween.interpolate_property(self, "modulate", self.modulate, color, duration, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()

func _on_Timer_timeout():
	queue_free()
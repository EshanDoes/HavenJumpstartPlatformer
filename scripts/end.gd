extends Label

@export var timeBetweenLetters = 2.0
@onready var timeLeft = timeBetweenLetters
var length = 3

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if visible_characters != length:
		timeLeft -= delta
	if timeLeft <= 0:
		visible_characters += 1
		timeLeft = timeBetweenLetters

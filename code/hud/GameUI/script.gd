extends CanvasLayer
class_name GameUI

## how much colas the player has
@export var colas_counter: int = 0:
	set(value):
		colas_counter = value
		_update_colas_counter()
## the text that shows when the player collects a cola
@export var colas_counter_text: String = "Colas: ":
	set(value):
		colas_counter_text = value
		_update_colas_counter()
@onready var colas: Label = $Colas

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_colas_counter()

func _update_colas_counter():
	if not colas: return
	colas.text = "Colas: "+str(colas_counter)

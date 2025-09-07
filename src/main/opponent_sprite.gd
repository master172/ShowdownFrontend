extends Sprite3D

@onready var info_component: Control = $SubViewport/InfoComponent

func reset():
	texture = null
	info_component.reset()

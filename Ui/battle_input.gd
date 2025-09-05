extends Control

@onready var options_container: HBoxContainer = $Panel/OptionsContainer
@onready var options_0: Control = $Panel/OptionsContainer/Options0
@onready var selected_option: Control = $Panel/OptionsContainer/SelectedOption
@onready var options_1: Control = $Panel/OptionsContainer/Options1

@onready var option_strings:Array = self.attack_strings

enum states {
	Attack,
	Switch,
	Inactive
}

@export var default_color :Color = Color(0,0,0)
@export var inactive_color :Color = Color(0,0,0)

var current_state :int = states.Attack

var max_selected:int = 0
var current_selected:int = 0

var attack_strings:Array = []
var switch_strings:Array = []


func _ready() -> void:
	#set_options(current_selected)
	if current_state == states.Inactive:
		modulate = inactive_color
	else:
		modulate = default_color

func update_strings(att_str:Array,sw_str:Array):
	attack_strings = att_str
	switch_strings = sw_str
	if current_state == states.Attack:
		option_strings = attack_strings
		max_selected = attack_strings.size()
	elif current_state == states.Switch:
		option_strings = switch_strings
		max_selected = switch_strings.size()
	set_options(current_selected)
	
func set_options(num:int)->void:
	selected_option.update_label(option_strings[num])
	options_0.update_label(option_strings[(current_selected + max_selected -1 )%max_selected])
	options_1.update_label(option_strings[(current_selected + 1) % max_selected])

func swap_states(state:int)->void:
	if state == states.Switch:
		option_strings = switch_strings
		max_selected = switch_strings.size()
		current_state = states.Switch
		
	elif state == states.Attack:
		option_strings = attack_strings
		max_selected = attack_strings.size()
		current_state = states.Attack
		
	current_selected = 0
	set_options(current_selected)
	
func _input(event: InputEvent) -> void:
	if current_state == states.Inactive:
		return
	
	if event.is_action_pressed("ui_left"):
		current_selected = (current_selected + max_selected -1 )%max_selected
		set_options(current_selected)
	elif event.is_action_pressed("ui_right"):
		current_selected = (current_selected + 1) % max_selected
		set_options(current_selected)
	elif event.is_action_pressed("No"):
		swap_states(states.Switch)
	elif event.is_action_pressed("Yes"):
		if current_state == states.Switch:
			swap_states(states.Attack)

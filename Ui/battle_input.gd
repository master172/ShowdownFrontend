extends Control

@onready var options_container: HBoxContainer = $Panel/OptionsContainer
@onready var options_0: Control = $Panel/OptionsContainer/Options0
@onready var selected_option: Control = $Panel/OptionsContainer/SelectedOption
@onready var options_1: Control = $Panel/OptionsContainer/Options1

@onready var option_strings:Array = self.attack_strings

signal request_move(move:String)

enum states {
	Attack,
	Switch,
	MustSwitch,
	Inactive,
	Lost
}

@export var default_color :Color = Color(0,0,0)
@export var inactive_color :Color = Color(0,0,0)

var current_state :int = states.Inactive

var max_selected:int = 0
var current_selected:int = 0

var attack_strings:Array = []
var switch_strings:Array = []


func _ready() -> void:
	#set_options(current_selected)
	modulate_active()
	
func modulate_active():
	if current_state == states.Inactive:
		modulate = inactive_color
	else:
		modulate = default_color

func reset():
	current_state = states.Inactive
	attack_strings = []
	switch_strings = []
	option_strings = []
	max_selected = 0
	modulate_active()
	
func set_lost():
	current_state = states.Lost
	
func active_pokemon_faineted(sw_str:Array):
	current_state = states.MustSwitch
	switch_strings = sw_str
	option_strings = switch_strings
	max_selected = switch_strings.size()
	current_selected = 0
	set_options(current_selected)
	
func update_strings(att_str:Array,sw_str:Array):
	if current_state == states.Lost:
		return
	attack_strings = att_str
	switch_strings = sw_str
	
	if att_str.size() == 0:
		current_state = states.MustSwitch
	if current_state == states.Inactive and att_str.size() > 0:
		set_active_after_switch()
		
	if current_state == states.Attack:
		option_strings = attack_strings
		max_selected = attack_strings.size()
	elif current_state == states.Switch:
		option_strings = switch_strings
		max_selected = switch_strings.size()
	elif current_state == states.MustSwitch:
		option_strings = switch_strings
		max_selected = switch_strings.size()
	current_selected = clamp(current_selected, 0, option_strings.size() - 1)
	set_options(current_selected)
	
func set_options(num:int)->void:
	if current_state == states.Inactive:
		return
	elif current_state == states.Lost:
		return
	selected_option.update_label(option_strings[num])
	options_0.update_label(option_strings[(current_selected + max_selected -1 )%max_selected])
	options_1.update_label(option_strings[(current_selected + 1) % max_selected])

func swap_states(state:int)->void:
	if current_state == states.Lost:
		return
		
	if state == states.Switch:
		if switch_strings.size() == 0:
			return
		option_strings = switch_strings
		max_selected = switch_strings.size()
		current_state = states.Switch
		
	elif state == states.Attack:
		option_strings = attack_strings
		max_selected = attack_strings.size()
		current_state = states.Attack
	elif state == states.Inactive:
		current_state = states.Inactive
	current_selected = 0
	set_options(current_selected)

func set_active_after_switch():
	if current_state == states.Lost:
		return
	current_state = states.Attack
	
func _input(event: InputEvent) -> void:
	if current_state == states.Inactive:
		return
	elif current_state == states.Lost:
		return
		
	if event.is_action_pressed("ui_left"):
		current_selected = (current_selected + max_selected -1 )%max_selected
		set_options(current_selected)
	elif event.is_action_pressed("ui_right"):
		current_selected = (current_selected + 1) % max_selected
		set_options(current_selected)
	elif event.is_action_pressed("No"):
		if current_state == states.Attack:
			swap_states(states.Switch)
		elif current_state == states.Switch:
			swap_states(states.Attack)
	elif event.is_action_pressed("Yes"):
		if current_state == states.Switch:
			emit_signal("request_move","s"+str(current_selected))
			swap_states(states.Inactive)
		elif current_state == states.Attack:
			emit_signal("request_move",str(current_selected))
		elif current_state == states.MustSwitch:
			emit_signal("request_move","s"+str(current_selected))
			swap_states(states.Inactive)

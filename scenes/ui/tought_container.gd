extends Control

var first_layer_change : bool = false
var intro_done : bool = false
var is_writting : bool = false
var intro_index : int = 0
var monologue_timer : float = 0.0

var cur_label : Label
var cur_text : String
var text_index : int = 0
var next_letter_interval : float = 0.2

const INTRO_INTERVAL = 2.0
const MARGIN_LABELS = 5
const MAX_LETTER_INTERVAL = 0.4
const MIN_LETTER_INTERVAL = 0.1

@onready var vbox := %VBoxContainer
@onready var ui_theme := preload("res://Ressources/ui_themes/monologue.tres")
@onready var rng = RandomNumberGenerator.new()

var monologues := {
	"intro": [
		"Ugh...",
		"My head... it hurts...",
		"What is this? I got some kind of helmet stuck on my head!",
		"Wait... is that... My thoughts? Written down?",
		"I see a green bar too! Is that... my... health status?",
		"Seems like I'm getting a bunch of informations out of this helmet.",
		"Ahg! I can't remove this helm... but i can feel some kind of keyhole on the left.",
		"I bet there's probably some key somewhere to unlock it.",
		"By the way... where am I?",
	],
	"intro_layer_change": [
		"There's also numbers down there... can I activate them somehow?",
	],
	"first_layer_change" : [
		"Woha... that felt fuzy.",
		"It's weird... it's almost like the world around me changed.",
	],
	"random_thoughts_once" : [
		"It's so weird to see your thoughts pop up. It's like in these weird 
			phone calls when you hear your own voice with a delay from the other side.",
		"I feel like I know this place. Wait, how did I get here?",
		"It's kind of strange... I have more thoughs than the ones that show on the screen... 
			I guess the helm filtering them? But why?",
		"Io... that's my name. Yes. Damn, I barely remember anything... is the helmet messing with my memory too?",
	],
	"random_thoughts" : [
		"Damn... this helmet is heavy. And itchy.",
		"Where is everyone? Am I alone out here?",
		"Laladila dada... ladiladila dadi",
		"How long have I been out?",
		"I don't remember anything...",
	]
}

func _process(delta) -> void:
	monologue_timer += delta
	if is_writting:
		write_text()
	elif !intro_done:
		monologue_intro()

func monologue_intro() -> void:
	if monologue_timer <= INTRO_INTERVAL:
		return
	monologue_timer = 0.0
	if monologues["intro"].size() <= intro_index + 1:
		intro_done = true
	instantiate_monologue_label(monologues["intro"][intro_index])
	intro_index += 1

func instantiate_monologue_label(text : String) -> void:
	if vbox.get_child_count() > 4:
		vbox.get_child(1).queue_free()
	var new_mbox = MarginContainer.new()
	new_mbox.add_theme_constant_override("margin_top", MARGIN_LABELS)
	new_mbox.add_theme_constant_override("margin_bot", MARGIN_LABELS)
	vbox.add_child(new_mbox)
	var new_hbox = HBoxContainer.new()
	new_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	new_mbox.add_child(new_hbox)
	var new_label = Label.new()
	new_label.set_autowrap_mode(TextServer.AUTOWRAP_WORD)
	new_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	new_label.theme = ui_theme
	new_hbox.add_child(new_label)
	is_writting = true
	cur_label = new_label
	cur_text = text
	text_index = 0

func write_text():
	if text_index >= cur_text.length():
		is_writting = false
		return
	if monologue_timer < next_letter_interval:
		return
	monologue_timer = 0.0
	cur_label.text += cur_text[text_index]
	text_index += 1
	calculate_next_letter_interval()

func calculate_next_letter_interval():
	if text_index >= cur_text.length():
		is_writting = false
		return
	if cur_text[text_index] == '.':
		next_letter_interval = 0.1
	if cur_text[text_index] == '?':
		next_letter_interval = 0.2
	else :
		next_letter_interval = 0.03

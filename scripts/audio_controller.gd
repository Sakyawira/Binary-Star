class_name NovelAudio
extends Node

@export var music: Array[AudioStream] = []
@export var aneska_voice: AudioStream
@export var yuvan_voice: AudioStream
@export var choice_move: AudioStream
@export var choice_confirm: AudioStream
@export var choice_volume_db := -8.0
@export var music_volume := 0.195
@export var fade_duration := 1.0

var players: Array[AudioStreamPlayer] = []
var voice: AudioStreamPlayer
var choice_audio: AudioStreamPlayer
var fade: Tween
var current_act := -1
var muted := false


func _ready() -> void:
	for stream in music:
		var player := AudioStreamPlayer.new()
		# Keep runtime loop points in Godot's mixer; web samples lose them.
		player.playback_type = AudioServer.PLAYBACK_TYPE_STREAM
		player.stream = _looping_copy(stream)
		player.volume_linear = 0.0
		add_child(player)
		players.append(player)
	voice = AudioStreamPlayer.new()
	add_child(voice)
	choice_audio = AudioStreamPlayer.new()
	choice_audio.volume_db = choice_volume_db
	add_child(choice_audio)


func _looping_copy(stream: AudioStream) -> AudioStream:
	var copy := stream.duplicate() as AudioStream
	if copy is AudioStreamWAV:
		copy.loop_mode = AudioStreamWAV.LOOP_FORWARD
		copy.loop_begin = 0
		copy.loop_end = int(copy.get_length() * copy.mix_rate)
	elif copy is AudioStreamMP3 or copy is AudioStreamOggVorbis:
		copy.loop = true
	return copy


func play_act(index: int) -> void:
	if index < 0 or index >= players.size() or index == current_act:
		return
	current_act = index
	if fade and fade.is_valid():
		fade.kill()
	if not players[index].playing:
		players[index].play()
	fade = create_tween().set_parallel(true)
	for i in players.size():
		fade.tween_property(players[i], "volume_linear", music_volume if i == index else 0.0, fade_duration)
	# Stop silent tracks, retaining only the current act after the crossfade.
	fade.chain().tween_callback(_stop_inactive_tracks)


func _stop_inactive_tracks() -> void:
	for i in players.size():
		if i != current_act:
			players[i].stop()


func start_voice(character: String) -> void:
	stop_voice()
	if character not in ["Aneska", "Yuvan"]:
		return
	voice.stream = _looping_copy(aneska_voice if character == "Aneska" else yuvan_voice)
	voice.play()


func stop_voice() -> void:
	voice.stop()


func on_choice_navigated() -> void:
	_play_choice_sound(choice_move)


func on_choice_selected(_index: int) -> void:
	_play_choice_sound(choice_confirm)


func _play_choice_sound(stream: AudioStream) -> void:
	# One UI voice prevents a held key from stacking sounds. Confirmation
	# replaces any cursor tick and continues after the menu closes.
	choice_audio.stream = stream
	choice_audio.play()


func set_muted(value: bool) -> void:
	muted = value
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), muted)


func reset() -> void:
	if fade and fade.is_valid():
		fade.kill()
	current_act = -1
	stop_voice()
	choice_audio.stop()
	for player in players:
		player.stop()
		player.volume_linear = 0.0


func on_phase_changed(phase: String) -> void:
	play_act({"day": 0, "twilight": 1, "evening": 2}[phase])


func on_dialogue_started(character: String, _emotion: String) -> void:
	start_voice(character)


func on_dialogue_completed(_character: String, _emotion: String) -> void:
	stop_voice()


func _exit_tree() -> void:
	# Release active playback before the audio server shuts down.
	reset()
	for player in players:
		player.stream = null
	voice.stream = null
	choice_audio.stream = null

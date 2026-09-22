extends Control
## Completed dialogue recedes toward a vanishing point above the current line.

const LINE_GAP := 32.0
const TRAVEL_DISTANCE := 1400.0
const FOCAL_DEPTH := 200.0

@export_range(1.0, 60.0, 0.5) var fade_duration := 24.0
@export_range(0.1, 3.0, 0.05) var handoff_duration := 1.0
@export_range(1, 8) var maximum_entries := 5

var entries: Array[Dictionary] = []


func _process(delta: float) -> void:
	for index in range(entries.size() - 1, -1, -1):
		var entry := entries[index]
		entry.age += delta
		entry.offset = lerpf(entry.offset, entry.target_offset, 1.0 - exp(-6.0 * delta))
		entry.distance = _travel(entry.age) + entry.offset
		if entry.age >= handoff_duration + fade_duration or entry.distance >= TRAVEL_DISTANCE:
			_remove_entry(index)
		else:
			_update_entry(entry)


func push_line(line: RichTextLabel) -> void:
	# Keep the actual typewriter node, its typography, and its exact screen position.
	line.reparent(self, true)
	var height := float(line.get_content_height())
	var minimum_distance := height + LINE_GAP
	for index in range(entries.size() - 1, -1, -1):
		var older := entries[index]
		# Shift older lines smoothly instead of teleporting them on each advance.
		older.target_offset = maxf(older.target_offset, minimum_distance - _travel(older.age))
		minimum_distance = _travel(older.age) + older.target_offset + older.height + LINE_GAP
	var entry := {
		"label": line, "height": height, "distance": 0.0, "age": 0.0,
		"offset": 0.0, "target_offset": 0.0,
		"start_position": line.position, "start_scale": line.scale,
		"start_modulate": line.modulate,
	}
	entries.append(entry)
	_update_entry(entry)
	while entries.size() > maximum_entries:
		_remove_entry(0)


func clear() -> void:
	while not entries.is_empty():
		_remove_entry(entries.size() - 1)


func finish_handoffs() -> void:
	# Explicit click-to-reveal also completes the departure so text cannot overlap.
	for entry in entries:
		entry.age = maxf(entry.age, handoff_duration)
		entry.offset = entry.target_offset
		entry.distance = _travel(entry.age) + entry.offset
		_update_entry(entry)


func _travel(age: float) -> float:
	var progress := clampf((age - handoff_duration) / fade_duration, 0.0, 1.0)
	return TRAVEL_DISTANCE * progress * progress


func _update_entry(entry: Dictionary) -> void:
	var line: RichTextLabel = entry.label
	var bottom: float = size.y * FOCAL_DEPTH / (FOCAL_DEPTH + entry.distance)
	var top: float = size.y * FOCAL_DEPTH / (FOCAL_DEPTH + entry.distance + entry.height)
	# Scale the entire paragraph uniformly, preserving upright, undistorted letters.
	var text_scale := (bottom - top) / maxf(entry.height, 1.0)
	var blend := smoothstep(0.0, handoff_duration, float(entry.age))
	line.scale = entry.start_scale.lerp(Vector2.ONE * text_scale, blend)
	line.position = entry.start_position.lerp(Vector2((size.x - line.size.x * text_scale) / 2.0, top), blend)
	var opacity := 0.58 * pow(clampf(1.0 - entry.distance / TRAVEL_DISTANCE, 0.0, 1.0), 1.6)
	line.modulate = entry.start_modulate.lerp(Color(0.75, 0.82, 0.92, opacity), blend)


func _remove_entry(index: int) -> void:
	var line: RichTextLabel = entries[index].label
	remove_child(line)
	line.queue_free()
	entries.remove_at(index)

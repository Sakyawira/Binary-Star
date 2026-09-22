extends PanelContainer
## Terminal-style navigation over the choices supplied by Ink.

signal selected(index: int)

const INACTIVE := Color("a1aec9")
const ACTIVE := Color("edc9f2")
const MUTED := Color("7383a5")

@onready var rows: VBoxContainer = $Content/Rows/Options
@onready var scroll: ScrollContainer = $Content/Rows
@onready var count_label: Label = $Content/Header/Count
@onready var shortcuts: Label = $Content/Shortcuts

var selected_row := -1
var options: Array = []
var appearance: Tween
var selected_style: StyleBoxFlat


func _ready() -> void:
	selected_style = StyleBoxFlat.new()
	selected_style.bg_color = Color(0.44, 0.34, 0.66, 0.15)
	selected_style.border_color = Color("b59acb")
	selected_style.border_width_left = 2
	rows.minimum_size_changed.connect(_fit_content.call_deferred)
	clear()


func present(choices: Array) -> void:
	clear()
	if choices.is_empty():
		return
	options = choices.duplicate(true)
	count_label.text = "%02d %s" % [options.size(), "OPTION" if options.size() == 1 else "OPTIONS"]
	shortcuts.text = "↑ ↓ navigate   ·   Enter confirm   ·   %s select" % ("1" if options.size() == 1 else "1–%d" % mini(9, options.size()))
	for index in options.size():
		_add_row(index, str(options[index].text))
	show()
	_select_row(0)
	scroll.scroll_vertical = 0
	_fit_content.call_deferred()
	modulate.a = 0.0
	appearance = create_tween()
	appearance.tween_property(self, "modulate:a", 1.0, 0.18)


func clear() -> void:
	if appearance and appearance.is_valid():
		appearance.kill()
	for row in rows.get_children():
		rows.remove_child(row)
		row.queue_free()
	options.clear()
	selected_row = -1
	hide()


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree() or not event is InputEventKey or not event.pressed:
		return
	var next := selected_row
	match event.keycode:
		KEY_UP:
			next = posmod(selected_row - 1, options.size())
		KEY_DOWN:
			next = posmod(selected_row + 1, options.size())
		KEY_TAB:
			next = posmod(selected_row + (-1 if event.shift_pressed else 1), options.size())
		KEY_HOME:
			next = 0
		KEY_END:
			next = options.size() - 1
		KEY_ENTER, KEY_KP_ENTER, KEY_SPACE:
			get_viewport().set_input_as_handled()
			if not event.echo:
				_commit(selected_row)
			return
		_:
			if event.keycode >= KEY_1 and event.keycode <= KEY_9:
				next = int(event.keycode - KEY_1)
			elif event.keycode >= KEY_KP_1 and event.keycode <= KEY_KP_9:
				next = int(event.keycode - KEY_KP_1)
			else:
				return
	get_viewport().set_input_as_handled()
	if next < options.size():
		_select_row(next)


func _add_row(index: int, text: String) -> void:
	var row := Button.new()
	row.custom_minimum_size.y = 58
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	row.accessibility_name = "%d. %s" % [index + 1, text]
	row.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	row.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	row.add_theme_stylebox_override("hover", selected_style)
	row.add_theme_stylebox_override("pressed", selected_style)
	rows.add_child(row)
	var inset := MarginContainer.new()
	inset.mouse_filter = Control.MOUSE_FILTER_IGNORE
	inset.add_theme_constant_override("margin_left", 18)
	inset.add_theme_constant_override("margin_right", 18)
	inset.add_theme_constant_override("margin_top", 10)
	inset.add_theme_constant_override("margin_bottom", 10)
	row.add_child(inset)
	inset.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var columns := HBoxContainer.new()
	columns.mouse_filter = Control.MOUSE_FILTER_IGNORE
	columns.add_theme_constant_override("separation", 12)
	inset.add_child(columns)
	for column in ["", "%d." % (index + 1), text]:
		var label := Label.new()
		label.text = column
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		columns.add_child(label)
	columns.get_child(0).custom_minimum_size.x = 24
	columns.get_child(1).custom_minimum_size.x = 48
	var response: Label = columns.get_child(2)
	response.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	response.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	response.minimum_size_changed.connect(func():
		row.custom_minimum_size.y = maxf(58.0, response.get_minimum_size().y + 20.0)
	)
	row.set_meta("columns", columns)
	row.focus_entered.connect(_select_row.bind(index))
	row.mouse_entered.connect(_select_row.bind(index))
	row.pressed.connect(_commit.bind(index))


func _select_row(index: int) -> void:
	if index < 0 or index >= rows.get_child_count():
		return
	selected_row = index
	for position in rows.get_child_count():
		var row: Button = rows.get_child(position)
		var columns: HBoxContainer = row.get_meta("columns")
		var active := position == index
		row.add_theme_stylebox_override("normal", selected_style if active else StyleBoxEmpty.new())
		columns.get_child(0).text = "›" if active else ""
		for column in columns.get_children():
			column.modulate = ACTIVE if active else INACTIVE
		if not active:
			columns.get_child(1).modulate = MUTED
	var focused: Button = rows.get_child(index)
	if not focused.has_focus():
		focused.grab_focus()
	_reveal_selection.call_deferred()


func _commit(position: int) -> void:
	if not visible or position < 0 or position >= options.size():
		return
	var ink_index := int(options[position].index)
	clear()
	selected.emit(ink_index)


func _fit_content() -> void:
	scroll.custom_minimum_size.y = minf(310.0, rows.get_combined_minimum_size().y)
	size.y = get_combined_minimum_size().y
	_reveal_selection.call_deferred()


func _reveal_selection() -> void:
	if selected_row >= 0 and selected_row < rows.get_child_count():
		scroll.ensure_control_visible(rows.get_child(selected_row))

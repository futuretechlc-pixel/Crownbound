extends Control
## Responsive menu shell. Buttons emit navigation requests for the app controller.

signal start_campaign_requested
signal quick_match_requested
signal daily_challenge_requested
signal local_match_requested
signal characters_requested
signal settings_requested

var root_box: VBoxContainer

func _ready() -> void:
    _build()

func _build() -> void:
    var background := ColorRect.new()
    background.color = Color("#080f25")
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(background)

    root_box = VBoxContainer.new()
    root_box.set_anchors_preset(Control.PRESET_CENTER)
    root_box.position = Vector2(-190, -235)
    root_box.custom_minimum_size = Vector2(380, 530)
    root_box.add_theme_constant_override("separation", 14)
    add_child(root_box)

    var title := Label.new()
    title.text = "CROWNBOUND"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 38)
    title.add_theme_color_override("font_color", Color("#ffd45c"))
    root_box.add_child(title)

    var subtitle := Label.new()
    subtitle.text = "THE BATTLE OF PATHS"
    subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    subtitle.add_theme_font_size_override("font_size", 14)
    subtitle.add_theme_color_override("font_color", Color("#a9c5ef"))
    root_box.add_child(subtitle)

    _add_menu_button("CAMPAIGN", start_campaign_requested.emit)
    _add_menu_button("QUICK MATCH VS AI", quick_match_requested.emit)
    _add_menu_button("DAILY CHALLENGE", daily_challenge_requested.emit)
    _add_menu_button("LOCAL MULTIPLAYER", local_match_requested.emit)
    _add_menu_button("CHARACTERS", characters_requested.emit)
    _add_menu_button("SETTINGS", settings_requested.emit)

    var footer := Label.new()
    footer.text = "Prototype build • Offline modes"
    footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    footer.add_theme_color_override("font_color", Color("#8192ad"))
    root_box.add_child(footer)

func _add_menu_button(caption: String, action: Callable) -> void:
    var button := Button.new()
    button.text = caption
    button.custom_minimum_size = Vector2(0, 52)
    button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    button.pressed.connect(action)
    root_box.add_child(button)

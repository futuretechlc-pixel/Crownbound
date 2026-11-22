extends Control
## App flow shell: main menu, campaign browser, and the existing 3D match.
const MENU_SCENE := preload("res://scenes/menus/main_menu.tscn")
const CAMPAIGN_SCENE := preload("res://scenes/menus/campaign_select.tscn")
const MATCH_SCENE := preload("res://scenes/main.tscn")
const HERO_SCENE := preload("res://scenes/menus/hero_select.tscn")

var active: Node
var selected_hero_id := "flare"

func _ready() -> void:
    _show_menu()

func _clear_active() -> void:
    if is_instance_valid(active):
        active.queue_free()
    active = null

func _show_menu() -> void:
    _clear_active()
    active = MENU_SCENE.instantiate()
    add_child(active)
    active.start_campaign_requested.connect(_show_campaign)
    active.quick_match_requested.connect(_start_match)
    active.daily_challenge_requested.connect(_start_daily_challenge)
    active.local_match_requested.connect(_show_local_notice)
    active.characters_requested.connect(_show_character_notice)
    active.settings_requested.connect(_show_settings_notice)

func _show_campaign() -> void:
    _clear_active()
    active = CAMPAIGN_SCENE.instantiate()
    add_child(active)
    active.back_requested.connect(_show_menu)
    active.level_selected.connect(_on_level_selected)

func _on_level_selected(level_id: int) -> void:
    _start_match(level_id)

func _start_daily_challenge() -> void:
    var date := Time.get_date_dict_from_system()
    var day_index := int(date.get("day", 1)) + int(date.get("month", 1)) * 31 + int(date.get("year", 2026)) * 366
    var level_id := posmod(day_index, 30) + 1
    _start_match(level_id, true)

func _start_match(level_id: int = 0, daily: bool = false) -> void:
    _clear_active()
    active = MATCH_SCENE.instantiate()
    active.set("campaign_level_id", level_id)
    active.set("selected_hero_id", selected_hero_id)
    active.set("is_daily_challenge", daily)
    add_child(active)

func _show_local_notice() -> void:
    _show_notice("LOCAL MULTIPLAYER", "Local hot-seat mode is planned. The current build is Human vs AI.")

func _show_character_notice() -> void:
    _clear_active()
    active = HERO_SCENE.instantiate()
    add_child(active)
    active.back_requested.connect(_show_menu)
    active.hero_chosen.connect(_on_hero_chosen)

func _on_hero_chosen(hero_id: String) -> void:
    selected_hero_id = hero_id
    _start_match()

func _show_settings_notice() -> void:
    _show_notice("SETTINGS", "Audio, language, graphics and accessibility settings will be added before release.")

func _show_notice(heading: String, message: String) -> void:
    _clear_active()
    var panel := VBoxContainer.new()
    panel.set_anchors_preset(Control.PRESET_CENTER)
    panel.position = Vector2(-210, -120)
    panel.custom_minimum_size = Vector2(420, 240)
    add_child(panel)
    active = panel
    var title := Label.new()
    title.text = heading
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 26)
    panel.add_child(title)
    var body := Label.new()
    body.text = message
    body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    body.custom_minimum_size = Vector2(0, 100)
    panel.add_child(body)
    var back := Button.new()
    back.text = "BACK TO MENU"
    back.pressed.connect(_show_menu)
    panel.add_child(back)

extends Control
signal level_selected(level_id: int)
signal back_requested

const CampaignManagerScript = preload("res://scripts/systems/campaign_manager.gd")
const SaveManagerScript = preload("res://scripts/systems/save_manager.gd")
var unlocked_level := 1
var save_manager = SaveManagerScript.new()

func _ready() -> void:
    save_manager.load_profile()
    var campaign_data: Dictionary = save_manager.profile.get("campaign", {})
    unlocked_level = int(campaign_data.get("unlocked_level", 1))
    _build()

func _build() -> void:
    var bg := ColorRect.new()
    bg.color = Color("#080f25")
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(bg)
    var panel := VBoxContainer.new()
    panel.set_anchors_preset(Control.PRESET_CENTER)
    panel.position = Vector2(-205, -300)
    panel.custom_minimum_size = Vector2(410, 600)
    add_child(panel)

    var heading := Label.new()
    heading.text = "CAMPAIGN: THREE REALMS"
    heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    heading.add_theme_font_size_override("font_size", 24)
    panel.add_child(heading)

    var progress := Label.new()
    progress.text = "UNLOCKED: %d / 30" % mini(unlocked_level, 30)
    progress.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    panel.add_child(progress)

    var manager = CampaignManagerScript.new()
    if not manager.load_campaign():
        return
    var scroll := ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    panel.add_child(scroll)
    var list := VBoxContainer.new()
    list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.add_child(list)

    var completed: Array = save_manager.profile.get("campaign", {}).get("completed_levels", [])
    var level_number := 1
    for world in manager.campaign.get("worlds", []):
        var world_title := Label.new()
        world_title.text = "%s  |  %s" % [world.get("name", "Realm"), world.get("description", "")]
        world_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        world_title.add_theme_font_size_override("font_size", 17)
        list.add_child(world_title)
        for level in world.get("levels", []):
            var id := int(level.get("id", level_number))
            var open := id <= unlocked_level
            var done := completed.has(id)
            var button := Button.new()
            var best_stars: Dictionary = save_manager.profile.get("best_stars", {})
            var star_count := int(best_stars.get(str(id), 0))
            var star_text := "★".repeat(star_count) + "☆".repeat(3 - star_count)
            button.text = "%02d  %s  •  %s  •  %d XP  %s%s" % [
                id, level.get("name", "Level"), level.get("difficulty", "Normal"),
                int(level.get("reward_xp", 0)), star_text, "  ✓" if done else ("" if open else "  🔒")]
            button.disabled = not open
            button.custom_minimum_size = Vector2(0, 46)
            button.pressed.connect(_on_level_pressed.bind(id))
            list.add_child(button)
            level_number += 1

    var back := Button.new()
    back.text = "BACK"
    back.custom_minimum_size = Vector2(0, 46)
    back.pressed.connect(back_requested.emit)
    panel.add_child(back)

func _on_level_pressed(level_id: int) -> void:
    level_selected.emit(level_id)

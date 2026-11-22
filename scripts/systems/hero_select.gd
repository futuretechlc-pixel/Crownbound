extends Control
signal hero_chosen(hero_id: String)
signal back_requested

const HEROES := [
    {"id":"flare","name":"FLARE","title":"The Ember Knight","ability":"BREAK WALL","desc":"Destroy one adjacent barrier. Best for aggressive route control.","color":Color("#ff5364")},
    {"id":"frost","name":"FROST","title":"The Glacier Mage","ability":"FROST LOCK","desc":"Freeze the next rival's movement. Best for tactical control.","color":Color("#48a7ff")},
    {"id":"vine","name":"VINE","title":"The Verdant Warden","ability":"QUICK ROUTE","desc":"Gain one extra legal move. Best for fast crown approaches.","color":Color("#59d68a")},
    {"id":"phantom","name":"PHANTOM","title":"The Veil Walker","ability":"PHASE STEP","desc":"Cross one blocked edge on your next move. Best for escape routes.","color":Color("#a78bfa")}
]
var chosen := "flare"
var description: Label
var chosen_label: Label

func _ready() -> void:
    _build()

func _build() -> void:
    var bg := ColorRect.new()
    bg.color = Color("#080f25")
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(bg)
    var panel := VBoxContainer.new()
    panel.set_anchors_preset(Control.PRESET_CENTER)
    panel.position = Vector2(-220, -285)
    panel.custom_minimum_size = Vector2(440, 570)
    panel.add_theme_constant_override("separation", 10)
    add_child(panel)
    var heading := Label.new()
    heading.text = "CHOOSE YOUR CHAMPION"
    heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    heading.add_theme_font_size_override("font_size", 26)
    panel.add_child(heading)
    var sub := Label.new()
    sub.text = "Each hero changes your signature ability."
    sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    panel.add_child(sub)
    for hero in HEROES:
        var button := Button.new()
        button.text = "%s  |  %s  |  %s" % [hero.name, hero.title, hero.ability]
        button.custom_minimum_size = Vector2(0, 62)
        button.add_theme_color_override("font_color", hero.color)
        button.pressed.connect(_choose.bind(hero.id))
        panel.add_child(button)
    chosen_label = Label.new()
    chosen_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    chosen_label.add_theme_font_size_override("font_size", 19)
    panel.add_child(chosen_label)
    description = Label.new()
    description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    description.custom_minimum_size = Vector2(0, 58)
    description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    panel.add_child(description)
    var start := Button.new()
    start.text = "START WITH THIS HERO"
    start.custom_minimum_size = Vector2(0, 52)
    start.pressed.connect(func(): hero_chosen.emit(chosen))
    panel.add_child(start)
    var back := Button.new()
    back.text = "BACK"
    back.pressed.connect(back_requested.emit)
    panel.add_child(back)
    _choose("flare")

func _choose(hero_id: String) -> void:
    chosen = hero_id
    for hero in HEROES:
        if hero.id == hero_id:
            chosen_label.text = "%s  •  %s" % [hero.name, hero.ability]
            chosen_label.add_theme_color_override("font_color", hero.color)
            description.text = hero.desc
            break

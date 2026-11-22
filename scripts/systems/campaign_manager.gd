extends RefCounted
class_name CrownboundCampaignManager

const CAMPAIGN_FILE := "res://resources/campaign/campaign_01.json"

var campaign: Dictionary = {}

func load_campaign() -> bool:
    if not FileAccess.file_exists(CAMPAIGN_FILE):
        push_error("Campaign file missing: " + CAMPAIGN_FILE)
        return false
    var file := FileAccess.open(CAMPAIGN_FILE, FileAccess.READ)
    if file == null:
        return false
    var parsed = JSON.parse_string(file.get_as_text())
    if not parsed is Dictionary or not parsed.has("worlds"):
        push_error("Campaign JSON has an invalid structure.")
        return false
    campaign = parsed
    return true

func get_level(level_id: int) -> Dictionary:
    for world in campaign.get("worlds", []):
        for level in world.get("levels", []):
            if int(level.get("id", -1)) == level_id:
                return level
    return {}

func is_level_unlocked(level_id: int, unlocked_level: int) -> bool:
    return level_id >= 1 and level_id <= unlocked_level and not get_level(level_id).is_empty()

func get_level_count() -> int:
    var total := 0
    for world in campaign.get("worlds", []):
        total += world.get("levels", []).size()
    return total

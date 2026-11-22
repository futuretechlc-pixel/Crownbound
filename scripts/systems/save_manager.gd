extends Node
class_name CrownboundSaveManager
## Local save foundation. Cloud sync can later merge this schema with server profiles.

const SAVE_PATH := "user://crownbound_profile.json"
const SCHEMA_VERSION := 1

var profile: Dictionary = {
    "schema_version": SCHEMA_VERSION,
    "player_name": "Crown Seeker",
    "xp": 0,
    "soft_currency": 0,
    "premium_currency": 0,
    "campaign": {"unlocked_level": 1, "completed_levels": []},
    "settings": {"music": 0.8, "sfx": 0.9, "quality": "medium"},
    "owned_cosmetics": [],
    "best_stars": {},
    "achievements": [],
    "stats": {"matches_played": 0, "matches_won": 0, "total_rounds": 0, "best_stars": 0},
    "daily_claims": []
}

func load_profile() -> void:
    if not FileAccess.file_exists(SAVE_PATH):
        save_profile()
        return
    var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file == null:
        push_warning("Crownbound save could not be opened.")
        return
    var parsed = JSON.parse_string(file.get_as_text())
    if parsed is Dictionary and int(parsed.get("schema_version", 0)) == SCHEMA_VERSION:
        profile = parsed
    else:
        push_warning("Unsupported or damaged save. A fresh profile will be created.")
        save_profile()

func save_profile() -> void:
    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file == null:
        push_error("Crownbound save could not be written.")
        return
    file.store_string(JSON.stringify(profile, "\t"))

func complete_level(level_id: int, xp_reward: int, coin_reward: int) -> bool:
    var campaign_data: Dictionary = profile.get("campaign", {"unlocked_level": 1, "completed_levels": []})
    var completed: Array = campaign_data.get("completed_levels", [])
    var first_completion := not completed.has(level_id)
    if first_completion:
        completed.append(level_id)
        profile["xp"] = int(profile.get("xp", 0)) + xp_reward
        profile["soft_currency"] = int(profile.get("soft_currency", 0)) + coin_reward
    campaign_data["completed_levels"] = completed
    campaign_data["unlocked_level"] = max(int(campaign_data.get("unlocked_level", 1)), level_id + 1)
    profile["campaign"] = campaign_data
    save_profile()
    return first_completion

func set_setting(key: String, value: Variant) -> void:
    var settings: Dictionary = profile.get("settings", {})
    settings[key] = value
    profile["settings"] = settings
    save_profile()


func grant_boss_reward(level_id: int, xp_bonus: int, coin_bonus: int) -> bool:
    var claimed: Array = profile.get("boss_rewards_claimed", [])
    if claimed.has(level_id):
        return false
    claimed.append(level_id)
    profile["boss_rewards_claimed"] = claimed
    profile["xp"] = int(profile.get("xp", 0)) + xp_bonus
    profile["soft_currency"] = int(profile.get("soft_currency", 0)) + coin_bonus
    save_profile()
    return true


func record_match_result(won: bool, rounds: int, stars: int, level_id: int, is_daily: bool) -> Dictionary:
    var stats: Dictionary = profile.get("stats", {})
    stats["matches_played"] = int(stats.get("matches_played", 0)) + 1
    stats["matches_won"] = int(stats.get("matches_won", 0)) + (1 if won else 0)
    stats["total_rounds"] = int(stats.get("total_rounds", 0)) + rounds
    stats["best_stars"] = maxi(int(stats.get("best_stars", 0)), stars)
    profile["stats"] = stats
    var best: Dictionary = profile.get("best_stars", {})
    if level_id > 0:
        best[str(level_id)] = maxi(int(best.get(str(level_id), 0)), stars)
    profile["best_stars"] = best
    var unlocked: Array[String] = []
    if won and int(stats.get("matches_won", 0)) == 1:
        unlocked.append("first_victory")
    if won and stars == 3:
        unlocked.append("three_star_performance")
    if won and rounds <= 8:
        unlocked.append("swift_conqueror")
    var new_achievements: Array[String] = []
    var achievements: Array = profile.get("achievements", [])
    for achievement_id in unlocked:
        if not achievements.has(achievement_id):
            achievements.append(achievement_id)
            new_achievements.append(achievement_id)
    profile["achievements"] = achievements
    var daily_reward := false
    if won and is_daily:
        var date_key := Time.get_date_string_from_system()
        var claims: Array = profile.get("daily_claims", [])
        if not claims.has(date_key):
            claims.append(date_key)
            profile["daily_claims"] = claims
            profile["xp"] = int(profile.get("xp", 0)) + 75
            profile["soft_currency"] = int(profile.get("soft_currency", 0)) + 35
            daily_reward = true
    save_profile()
    return {"new_achievements": new_achievements, "daily_reward": daily_reward}

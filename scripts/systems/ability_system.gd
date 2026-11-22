extends RefCounted
class_name CrownboundAbilitySystem
## Deterministic ability validation helpers; visual effects are handled by scenes.

static func can_cast(character: Dictionary, energy: int, cooldown_remaining: int) -> bool:
    var ability: Dictionary = character.get("ability", {})
    return energy >= int(ability.get("cost", 999)) and cooldown_remaining <= 0

static func apply_energy_cost(character: Dictionary, energy: int) -> int:
    var ability: Dictionary = character.get("ability", {})
    return max(0, energy - int(ability.get("cost", 0)))

static func cooldown_after_cast(character: Dictionary) -> int:
    var ability: Dictionary = character.get("ability", {})
    return int(ability.get("cooldown_turns", 0))

static func validate_target_in_bounds(cell: Vector2i, board_size: int) -> bool:
    return cell.x >= 0 and cell.y >= 0 and cell.x < board_size and cell.y < board_size

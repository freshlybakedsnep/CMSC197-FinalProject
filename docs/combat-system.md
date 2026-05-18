# Combat System

## Simultaneous Turn-based Combat
Both the player and enemies decide their actions before the Combat Phase begins.
Actions are resolved in sequence according to Action Order.

## Combat Parameters
### Base Stats
- HP (Health Points)
- ATK (Attack)
- DEF (Defense)
- SPD (Speed)

### Dynamic Stats
Combat values may change during battle due to:
- Buffs
- Debuffs
- Status effects
- Skills

## Status Effects
Status effects alter combat behavior, stats, targeting, or action availability.
Buffs and debuffs modify combat parameters dynamically.

Effects may expire based on:
- Duration
- Number of hits
- Number of activations 
- Combination conditions

### Trigger-based Status Effects
Some status effects also respond to specific combat events.
Examples:
- Turn Start
- Turn End
- Taking Damage
- Performing Actions

This allows effects to behave dynamically instead of relying solely on duration timers.

For technical implementation details, see:
- `status-effects.md`

## Elemental Counter System

| Element | Strong Against | Weak Against |
|---|---|---|
| Fire | Wood | Water |
| Wood | Water | Fire |
| Water | Fire | Wood |
| Light | Dark | Dark |
| Dark | Light | Light |

## Class/Role System

| Class | Role |
|---|---|
| Duelist | DPS |
| Juggernaut | Tank |
| Supporter | Recovery |
| Tactician | Buff/CC |
| Vandal | Debuffer/SubDPS |

## Skill Types
### Basic Attack
- No cooldown

### Guard
- Defensive action
- Reduces incoming damage

### Skill
- May have cooldowns
- Character-specific

### EX Skill
- Powerful effects

## Combat Resolution Flow
```text
Turn Start
    ↓
Status Trigger Processing
    ↓
Planning Phase
    ↓
Combat Resolution
    ↓
Turn Queue Generation
    ↓
Action Execution
    ↓
Async Trigger Resolution
    ↓
Death Cleanup
    ↓
Wave Validation
    ↓
Turn End
```

## Dynamic Action Order System

Action order is recalculated dynamically throughout combat.

Turn priority is determined by:
1. Action Priority
2. SPD (Speed)

Entities are excluded from the queue if:
- Eliminated
- Already acted
- Incapacitated
- Removed from battle

This allows:
- Dynamic SPD manipulation
- Mid-turn combat adjustments
- Reactive turn sequencing

## Damage Resolution

Combat damage is resolved through the Combat Resolver system.

Damage calculation may include:
- Defense mitigation
- Elemental multipliers
- Damage reduction states
- Invulnerability checks
- Piercing effects

Status effects may also trigger additional combat behavior during damage resolution.
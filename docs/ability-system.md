# Ability System

## Overview

Abilities are implemented as resource-driven Action objects.

Each Action contains:
- Targeting rules
- Cooldowns
- Resource costs
- Priority values
- Arrays of Effect Groups

This allows abilities to remain modular, scalable, and highly configurable without hardcoding combat behavior.

---

## Action Structure

Each Action defines:
- Action Name
- Description
- Icon
- Cooldown
- Cost
- Priority
- Targeting Rules
- Effect Groups

```text
Action
├── Target Rules
├── Cooldown
├── Cost
├── Priority
└── EffectGroups[]
      ├── EffectGroup
      │     ├── Target Override
      │     └── Effects[]
      │           ├── HealthEffect
      │           └── StatusEffect
```


## Targeting Configuration

### Target Groups
| Type | Description |
|---|---|
| SELF | Targets self |
| ALLY_ONLY | Targets allies excluding self |
| PARTY | Targets all allies |
| ENEMY | Targets enemy units |

### Target Modes
| Mode | Description |
|---|---|
| SINGLE | Single target |
| MULTIPLE | Multiple selected targets |
| AOE | All valid targets |
| RANDOM | Random valid targets |

### Target States
| State | Description |
|---|---|
| ALIVE | Living targets only |
| DEAD | Dead targets only |
| ANY | Any target |

---

## Effect Groups

Actions may contain multiple Effect Groups.

Each Effect Group may:
- Inherit the Action’s target rules
- Override targeting behavior
- Contain multiple Effects

This allows abilities to:
- Damage enemies while buffing allies
- Apply multiple effects simultaneously
- Resolve complex targeting logic modularly

Effect Groups are resolved sequentially during action execution.

---

## Effect Types

### Health Effects
Used for:
- Damage
- Healing
- Piercing attacks
- Defense-ignoring attacks

### Status Effects
Used for:
- Buffs
- Debuffs
- Crowd control
- Damage-over-time effects
- Special combat flags

Status Effects integrate directly with the Status Component system and may apply combat modifiers, restrictions, or asynchronous effects.
---

## Formula-driven Values

Combat values are calculated using modular Formula Resources.

Supported formula types include:
- Flat values
- Scaling values
- Composite formulas

This allows abilities to scale dynamically based on combat stats and ability level.

## Action Execution
Actions are executed through the Action Parser system.

Execution flow:
1. Validate targets
2. Consume resources
3. Apply cooldowns
4. Resolve targeting
5. Apply effects
6. Trigger combat events

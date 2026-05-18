# Status Effect System

## Overview

The status effect system is an event-driven combat subsystem responsible for:
- Buffs and debuffs
- Crowd control effects
- Damage-over-time effects
- Targeting restrictions
- Defensive states
- Trigger-based combat interactions

Status effects are processed through the `StatusComponent`.

---

## Status Architecture

Active status effects are grouped by behavior type and status key.

```text
Behavior Category
└── Status Key
      └── Effect Instances
```

This structure allows:
- Multiple instances of the same status
- Efficient behavioral lookups
- Trigger-based processing
- Modular combat interaction handling

---

## Behavior Categories

Status effects are categorized by behavioral purpose.

| Behavior | Description |
|---|---|
| NONE | Standard stat modifiers |
| INCAPACITATE | Prevents unit actions |
| RESTRICT | Restricts targeting or action choices |
| PROTECT | Defensive or targeting protection effects |
| EOT | Effect-over-time or asynchronous effects |

---

## Status Instances

Each status instance may contain:
- Turn duration
- Hit duration
- Trigger conditions
- Magnitude values
- Caster reference
- Removal rules

Statuses may:
- Stack independently
- Refresh existing durations
- Be unique
- Be permanent
- Expire conditionally

---

## Expiration System

Status effects support multiple expiration methods.

### Turn-based Expiration
Effects expire after a specified number of turns.

### Hit-based Expiration
Effects expire after triggering a specified number of times.

### Permanent Effects
Permanent effects ignore normal expiration rules until explicitly removed.

---

## Trigger-based Processing

Status effects may respond dynamically to combat events.

Supported triggers include:
- On Attack
- On Defend
- On Turn Start
- On Turn End
- On Follow-up

Trigger processing allows combat effects to react dynamically during battle resolution.

---

## Damage-over-Time Effects

Asynchronous effects such as poison or burn are processed independently from the primary combat action flow.

These effects:
- Trigger through combat events
- Generate deferred combat events
- Resolve through asynchronous combat states

This allows delayed effects to resolve cleanly without interrupting the main combat sequence.

---

## Targeting-related Status Effects

Some status effects modify targeting behavior.

### Taunt
Forces opposing units to prioritize the entity.

### Provoke
Restricts the affected unit’s valid targets.

### Untargetable
Prevents entities from being selected as valid enemy targets.
This only takes effect when there are other targets in the field and who do not have the same status.

---

## Incapacitation Effects

Certain status effects prevent units from acting.

Examples include:
- Stun
- Sleep
- Action lock effects

Incapacitated entities automatically skip action execution during combat resolution.

---

## Status Flags

Certain combat states are represented through status flags.

Examples:
- DEFEND
- INVULNERABLE
- PIERCE
- SILENCE

Flags allow combat logic to remain modular and centralized without requiring hardcoded skill behavior.

---

## Design Goals

The status system is designed to:
- Support scalable combat interactions
- Allow modular status creation
- Minimize hardcoded combat logic
- Enable event-driven combat behavior
- Support complex conditional effects
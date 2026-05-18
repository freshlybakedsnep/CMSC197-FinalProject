# Targeting System

## Overview

The targeting system dynamically resolves valid targets during combat based on:
- Target group
- Target mode
- Target state
- Status conditions
- Targetability rules

---

## Target Resolution

Targets are resolved through the `TargetingResolver`.

The resolver:
- Retrieves valid target pools
- Applies state filtering
- Applies status-based targeting restrictions
- Returns valid combat targets

---

## Target Priority Rules

Certain status effects override normal targeting behavior.

### Provoke
Provoked units prioritize attacking the provoking entity.

### Taunt
Units with Taunt force enemies to target them when possible.

### Untargetable
Untargetable units are excluded from valid enemy targets.

Some targeting restrictions are dynamically enforced through the Status Effect system.

---

## Target Modes

### Single Target
Selects one valid entity.

### Multiple Target
Selects multiple entities up to a configured limit.

### Area of Effect (AOE)
Targets all valid entities in the target group.
Ignores Provoke and Taunt statuses.

### Random
Selects random valid entities.

---

## Effect-level Targeting

Effect Groups may override an Action’s primary targeting configuration.

This allows:
- Hybrid ally/enemy abilities
- Secondary effects
- Split targeting behaviors

--- 

## Target Validation
Before targets are finalized, the targeting system validates:
- Combat state
- Target availability
- Targetability restrictions
- Status effect conditions

Invalid targets are automatically removed from selection pools.

---

## Dynamic Retargeting

If initial targets become invalid during execution, actions may dynamically resolve new valid targets depending on targeting rules and effect configuration.
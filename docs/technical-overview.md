# Technical Overview

## Related Documentation

- `game-design.md`
- `combat-system.md`
- `ability-system.md`
- `targeting-system.md`
- `status-effects.md`

---

## Core Architecture

The project emphasizes modular combat systems, scalable gameplay logic, and data-driven content design.

Core gameplay systems are separated into reusable components and orchestrated through a finite state machine-based combat flow.

---

## Major Systems

### Database System

The project uses a resource-driven data architecture for gameplay content management.

Reusable Godot Resource objects are used to store:
- Character data
- Enemy data
- Ability definitions
- Stage information

These resources act as configurable gameplay templates that are instantiated and initialized during runtime combat setup.
---

## Finite State Machine (FSM)

Combat flow is orchestrated through a stack/state-based FSM system.

Implemented battle states include:
- Turn Start
- Planning Phase
- Combat Resolution
- Acting State
- Turn End
- Asynchronous Effect Processing
- Victory State
- Defeat State

The FSM allows combat flow to:
- Pause for asynchronous effects
- Process chained triggers
- Handle dynamic combat events
- Maintain scalable combat sequencing

---

## Combat Flow Architecture

```text
TurnStart
    ↓
Apply Turn-based Effects
    ↓
PlanState
(Player/AI select actions)
    ↓
CombatState
(Resolve combat queue)
    ↓
ActingState
(Execute entity action)
    ↓
AsyncEffectState
(Process delayed effects)
    ↓
TurnEnd
    ↓
Cleanup / Wave Validation
    ↓
Next Turn
```

---

## Entity-Component System

Combat entities are built using a composition-based architecture rather than deep inheritance hierarchies.

Gameplay functionality is separated into modular components that can be independently initialized and accessed at runtime.

---

## Entity Architecture

Combat entities are divided into three primary layers:

```text
Entity Node
    ↓
EntityData Resource
    ↓
Entity Components
```

This separation allows gameplay logic, visual representation, and combat systems to remain modular and scalable.

---

### Entity

`Entity` represents the in-battle scene object.

Responsibilities include:
- Visual presentation
- Animation playback
- User interaction
- UI integration
- Combat feedback
- Signal forwarding

Entities act as the runtime representation of combat units within the scene tree.

---

### EntityData

`EntityData` stores gameplay-related information independently from scene logic.

Responsibilities include:
- Combat state
- Faction data
- Entity metadata
- Component ownership
- Runtime component access

Each entity maintains a component registry that allows systems to dynamically retrieve required functionality.

---

### Entity Components

Gameplay functionality is separated into modular components.

Current component categories include:

| Component | Responsibility |
|---|---|
| StatsComponent | Combat statistics and health |
| ElementComponent | Elemental typing and effectiveness |
| ActionComponent | Abilities and cooldown management |
| ResourceComponent | MP/resource handling |
| ControllerComponent | AI and player decision handling |
| StatusComponent | Buffs, debuffs, and status processing |

Components are duplicated and initialized per entity instance during combat setup.

This prevents unintended shared runtime state between entities while preserving reusable configuration templates.

---

### Runtime Initialization

During battle initialization:
1. Entity resources are duplicated
2. Components are initialized
3. Runtime references are assigned
4. Combat systems register the entity

This enables battle entities to maintain isolated runtime state while sharing reusable configuration resources.

---

## Controller Architecture

Combat decisions are separated from combat execution through controller components.

Controllers are responsible only for:
- Selecting actions
- Selecting targets
- Queuing combat decisions

Combat resolution itself is handled independently by the combat pipeline.

Current controller implementations include:

| Controller | Responsibility |
|---|---|
| PlayerController | Handles player-selected actions and targets |
| AIController | Generates automated combat decisions for enemies |

Both controllers interface with the same:
- Action system
- Targeting system
- Combat execution pipeline

This ensures that AI-controlled and player-controlled entities follow identical combat rules.

---

### PlayerController

The player controller stores queued combat decisions selected through the command UI.

Responsibilities include:
- Action validation
- Cooldown validation
- Queue management
- Target storage

Actions are not executed immediately and are instead resolved later during the combat phase.

---

### AIController

The AI controller currently uses randomized decision-making for action and target selection.

Behavior includes:
- Random ability selection
- Ultimate prioritization when resources are full
- Randomized target selection through the targeting system

Although simple, the controller architecture allows future expansion into:
- Weighted decision-making
- Conditional skill usage
- Threat evaluation
- Team synergy logic
- Behavior trees or utility AI systems

---

## Status Effect Architecture

Status effects are implemented through an event-driven component system.

Effects are grouped by behavior category and processed through trigger-based combat events, allowing asynchronous and conditional combat interactions without hardcoded action logic.

---

## Event and Trigger Processing

Combat events may generate deferred effects stored in a pending trigger queue.

Examples include:
- Damage-over-time effects
- Status effect ticks
- Delayed effect resolution

Pending effects are processed through a dedicated asynchronous combat state, allowing chained effects and combat events to resolve independently from the primary action flow.

---

## Ability System

Abilities are resource-driven data objects that define combat behavior independently from entity implementation.

Abilities consist of:
- Targeting rules
- Cooldowns
- Costs
- Arrays of Effects

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

### ActionComponent

`ActionComponent` manages an entity's available abilities and runtime combat action state.

Responsibilities include:
- Ability slot bindings
- Action pools
- Cooldown tracking
- Action priority handling

Actions are separated into multiple categories:

| Category | Purpose |
|---|---|
| Basic Actions | Standard actions without cooldown |
| Guard Actions | Defensive priority actions |
| Skills | Cooldown/resource-based abilities |
| Ultimates | High-cost powerful abilities |

The component also stores runtime cooldown information independently from the underlying action resources.

This separation allows:
- Shared reusable action definitions
- Isolated runtime combat state
- Dynamic action loadouts
- Future customization systems

Guard actions override normal action priority and are designed to resolve before standard combat actions.

---

## Effect System

Effect categories include:
- Immediate Health Effects (Damage and Healing)
- Stat Manipulation
- Status Conditions

---

## Persistence Systems

### HeroDatabase

Tracks:
- Unlocked heroes
- Deployable heroes
- Hero information

### Party Manager

Retains:
- Party composition
- Battle progression state
- Persistent combat values

---

## Design Goals

The combat architecture is designed to:
- Reduce hardcoded combat logic
- Improve system modularity
- Simplify feature expansion
- Separate gameplay state from visuals
- Support scalable combat interactions

---

## Planned Extensions

Additional FSM states may be introduced later for:
- Cutscenes
- Dialogue sequences
- Cinematic combat events
- Follow-up attack chains
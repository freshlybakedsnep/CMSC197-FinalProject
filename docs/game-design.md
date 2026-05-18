# Game Design Document

## Overview
A simultaneous turn-based strategy RPG focused on team composition, tactical decision-making, elemental interactions, and status effect management.
The player assembles a party of up to five playable characters and progresses through battle stages consisting of multiple enemy waves.

## Genre
- Turn-based Strategy RPG
- Party-based Combat RPG
- Type Advantage Combat System

## Inspirations
- Fate/Grand Order
- Honkai: Star Rail
- Pokemon Series
- Fire Emblem
- Final Fantasy Series
- Dislyte
- Miitopia

## Core Gameplay Loop

### General Flow
Menu → Level Select → Hero Select → Battle Stage

### Battle Flow

```text
Turn Start
    ↓
Planning Phase
    ↓
Combat Resolution
    ↓
Turn End
```

## Battle Phases
Players and enemies commit actions simultaneously during the Planning Phase.
Actions are then resolved sequentially during the Combat Phase according to dynamic Action Order calculations.

### Strategizing Phase
Players assign actions for all active heroes:
- Select skill/action
- Select target
- Revise actions before confirmation

### Combat Phase
All units perform actions according to Action Order:
- Action Order is determined by SPD
- Units with Higher SPD act first
- SPD modifications dynamically alter turn order

## Victory and Defeat Conditions

### Victory
- Defeat all enemy waves

### Defeat
- All party members are incapacitated

## Core Combat Principles

The game emphasizes:
- Team composition
- Turn planning
- Dynamic action order
- Elemental interactions
- Status effect management
- Resource management
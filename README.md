# Seed Actions

Seed Actions is a Godot turn-based strategy RPG prototype focused on party building,
resource-driven combat data, status effects, elemental matchups, and simultaneous
turn planning. The player moves through a world map, enters battle gates, builds a
party from unlocked heroes, clears multi-wave stages, and unlocks more characters
through progression.

This is a student project built for CMSC 197. The project prioritizes combat
architecture and playable RPG flow over final art polish.

## Current Gameplay Flow

```text
Main Menu
  -> New Game / Continue
  -> Intro
  -> World Map
  -> Battle Gate
  -> Party Selection
  -> Battle Stage
  -> Result Screen
  -> World Map / Ending / Main Menu
```

The core loop is already implemented around a world map, battle nodes, party
selection, staged encounters, win/lose result handling, and saved progression.

## Features

- Simultaneous turn-based combat where heroes and enemies commit actions before
  combat resolution.
- Party-based team building with up to five heroes.
- Unlockable hero progression based on cleared battle nodes.
- Multi-wave battle stages.
- Resource-driven heroes, enemies, abilities, effects, battle nodes, and
  locations.
- Elemental typing and combat stat components.
- Status effect processing for buffs, debuffs, and conditions.
- Skill, guard, ultimate, cooldown, and resource systems.
- World map navigation with battle gates and service nodes.
- Separate pause flows for world exploration and battle.
- BGM and SFX managers wired through Godot autoloads.

## Tech Stack

- Godot 4.x project, currently configured with Godot 4.6 compatibility settings.
- GDScript.
- Godot `Resource` files for data-driven gameplay content.
- Godot scenes for menus, world navigation, party selection, combat, and UI.

## Running the Project

1. Install Godot 4.6 or a compatible Godot 4.x version.
2. Open Godot.
3. Import this repository by selecting `project.godot`.
4. Run the project with the editor play button or `F5`.

The configured main scene is:

```text
res://scenes/menu/main_menu.tscn
```

Progress is stored locally in:

```text
res://user/progress/progress.cfg
```

Use the in-game New Game flow to reset progress, or delete the local progress file
while testing.

## Controls

- Use the mouse or UI focus navigation to select menu options, party members,
  skills, and targets.
- Use `Esc` / `ui_cancel` to open pause menus where available.
- In battle, select actions for the party, choose targets, then confirm to resolve
  the turn.

## Project Structure

```text
assets/                 Imported images, fonts, audio, BGM, SFX, and voice clips
docs/                   Design and technical documentation
resources/ability/      Ability, effect, and value formula resources
resources/battles/      Battle node resources used by the world map
resources/enemies/      Enemy data resources
resources/heroes/       Runtime hero data resources loaded by HeroDatabase
resources/locations/    World map location resources
resources/stages/       Stage and wave resources
scenes/entity/          Entity, hero, enemy, HP bar, and AI logic scripts/scenes
scenes/menu/            Main menu and ending screens
scenes/menu_ui/         Battle UI, hero HUD, result modal, cursor, and tooltips
scenes/party_select/    Party selection scene and character slots
scenes/player_world/    World map, intro, gates, services, and map pause modal
scenes/stage_prelim/    Battle stage, formations, battle pause modal, and VFX UI
scripts/                Shared systems, components, policies, state machine, globals
```

## Core Systems

### Data-Driven Content

Most gameplay content is configured through Godot resources instead of hardcoded
scene logic. Heroes, enemies, abilities, effects, value formulas, locations, battle
nodes, and stages can be adjusted through `.tres` files.

Important resource types include:

- `HeroData` in `scenes/entity/ent_hero.gd`
- `EnemyData` in `scenes/entity/ent_enemy.gd`
- `Action`, `Effect`, `EffectGroup`, and value formulas in `scripts/action/`
- `LocationData` in `scripts/location_data.gd`
- `BattleNodeData` in `scripts/battle_node_data.gd`
- `StageInfo` and `Wave` in `scripts/stage_info.gd` and `scripts/wave.gd`

### Combat Flow

Combat is controlled by a finite state machine and a set of battle policy helpers.
The player plans actions first, then combat resolves queued actions based on the
runtime combat rules.

Main files:

- `scenes/stage_prelim/stage.gd`
- `scripts/battle_events.gd`
- `scripts/state_machine.gd`
- `scripts/policies/battle_registry.gd`
- `scripts/policies/action_parser.gd`
- `scripts/policies/combat_resolver.gd`
- `scripts/policies/target_resolver.gd`

### Entity Components

Combat units use a composition-style setup. Entity data owns components for stats,
elements, resources, actions, controllers, and statuses. Components are duplicated
and initialized for runtime battles so reusable templates do not accidentally share
combat state.

Main component files:

- `scripts/components/stats_component.gd`
- `scripts/components/element_component.gd`
- `scripts/components/resource_component.gd`
- `scripts/components/action_component.gd`
- `scripts/components/player_controller.gd`
- `scripts/components/ai_controller.gd`
- `scripts/components/status_component.gd`

### World, Party, and Progression

The world map renders location resources and creates gates for battle nodes. When
the player selects a battle gate, the game opens party selection, stores the active
battle metadata, starts the stage, and applies win-based unlocks after victory.

Main files:

- `scripts/components/world_controller_component.gd`
- `scenes/player_world/world.tscn`
- `scenes/player_world/warp_gate.gd`
- `scenes/party_select/party_selection.gd`
- `scripts/globals/party_manager.gd`
- `scripts/globals/hero_database.gd`

## Editing Content

Common content-editing entry points:

- Add or update playable heroes in `resources/heroes/`.
- Add or update enemy resources in `resources/enemies/`.
- Tune abilities, effects, cooldowns, and formulas in `resources/ability/`.
- Tune stages and waves through `StageInfo` and `Wave` resources.
- Add world encounters through `resources/battles/` and `resources/locations/`.
- Set battle rewards and unlocks through `BattleNodeData.unlock_heroes`.

When adding a new hero, make sure the `HeroData.entity_name` matches any unlock name
used by battle nodes, because hero unlocking uses exact name matching.

## Documentation

- [Game Design Document](docs/game-design.md)
- [Combat System](docs/combat-system.md)
- [Ability System](docs/ability-system.md)
- [Targeting System](docs/targeting-system.md)
- [Status Effect System](docs/status-effects.md)
- [Technical Overview](docs/technical-overview.md)

## Project Status

Implemented:

- Main menu, intro, world map, party selection, battle stage, and result flow.
- Resource-driven hero, enemy, ability, stage, location, and battle data.
- Core combat state machine and action resolution pipeline.
- Party selection and saved progression.
- Battle/world pause modals.
- BGM and SFX playback managers.

Still incomplete or subject to polish:

- Final art direction and consistent production assets.
- Expanded stage and encounter content.
- More advanced AI decision-making.
- More animation and combat presentation polish.
- Formal export/package workflow.

## Asset and License Notice

This repository is a non-commercial student project made for academic and portfolio
purposes. It includes third-party visual and audio assets that may belong to their
respective creators or publishers.

Do not assume the included assets are free to reuse in another project. Check each
asset source and license before redistribution, publication, or commercial use.

No standalone open-source license file is currently included in this repository.

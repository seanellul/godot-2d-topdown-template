# Entities

All characters in the game, including main characters, enemies, and NPCs, are defined as entities.
The base node for entities is `entity.tscn`, which has the script `character_entity.gd` (CharacterEntity) attached.
The CharacterEntity class inherits from CharacterBody2D and is used to control everything about the entity, including actions (movement, jumping, attack), animations, states, and energy.
There are nodes that inherit from the `entity.tscn` node for more specific handling, such as:

- `player.tscn`, with the attached script `player_entity.gd` (PlayerEntity), which inherits from CharacterEntity
- `enemy.tscn`
  Below, we explore the structure of CharacterEntity and its management, then move on to specifics of the PlayerEntity class.

## entity.tscn

The `entity.tscn` node is structured as follows:

- Entity (`character_entity.gd`)
  - CollisionShape2D
  - Shadow
  - Sprite2D
  - BlocksDetector
  - FallDetector
  - AnimationPlayer
  - AnimationTree

### Entity

CharacterEntity < CharacterBody2D <br>
All properties and methods in the `character_entity.gd` script have comments.
You can check the comments to better understand the functionality of the script.

### CollisionShape2D

CollisionShape2D used by CharacterBody2D. It provides a collider for the entity, set to level 2 (character), and scans all colliders on levels 1 (block), 2 (character), and 3 (body).

### Shadow

Sprite2D that represents a shadow beneath the entity.

### Sprite2D

The main Sprite2D representing the entity.

### BlocksDetector

RayCast2D to identify when the entity is facing a blocking element, such as a wall or object. It scans levels 1 (block) and 3 (body). The rotation is synchronized with the direction the entity is facing, as this node is added to the `sync_rotation` array of CharacterEntity.

### FallDetector

ShapeCast2D to identify when the entity is in an unsafe position. A safe position is one where the entity can move freely. This is useful for identifying cliffs and making the entity “fall” when over them. It scans level 3 (body) and triggers the `on_fall` state of CharacterEntity when it collides.

### AnimationPlayer

The main AnimationPlayer that manages all entity animations. Animations are divided into libraries, where each library represents a specific animation (e.g., idle, jump, attack) containing 4 animations, one for each direction (down, left, right, up). For more information on animations, see the Animations section.

### AnimationTree

The main AnimationTree that manages the entity's various animations. Animations are controlled by a state machine, with each animation linked to the entity's current action (see the "Actions" group of CharacterEntity). For more information on animations, see the Animations section.

## player.tscn

The `player.tscn` node inherits from `entity.tscn`. Here, we explore nodes that are not already present in the parent node:

- Player (`player_entity.gd`)
  - SmokeParticles
  - InteractionTrigger
  - StateMachine (`state_machine.gd`)

### Player

PlayerEntity < CharacterEntity <br>
All properties and methods in the `player_entity.gd` script have comments. You can check the comments to better understand the functionality of the script.

### SmokeParticles

GPUParticles2D whose emission is activated when the entity is running (see `running_particles` in CharacterEntity).

### InteractionTrigger

Area2D defining the area that allows the entity to interact with interactive elements. Interactions can be triggered by the StateInteract state. For more information on states, see the State Machine section.

### StateMachine

StateMachine that controls all possible states of this entity. For more information, see the State Machine section.

## Animations

---

# Levels

A level is a game area where playable characters, NPCs, any enemies, and props are present. The base node for levels is `Level.tscn`, which has attached the script `level.gd`. The Level node can be used as a starting node for creating new levels. It already has a structure of nodes within it, making it fully functional. Exploring the present nodes, we find:

- GameCamera2D
- Layers
- Props
- Entities
- Transfers
- Events

## GameCamera2D

The main GameCamera2D of the level. It has the script `game_camera.gd` attached, useful to define a camera's target to follow:

- `target_player_id`: You can set a value corresponding to the `player_id` of the player to follow (see PlayerEntity). Setting a value greater than 0 will search within the level for the player with the corresponding player_id. Setting the value to 0 will not search for any player, and only the `target` field will be checked.
- `target`: If you want the camera to follow any node (that is not a player), you can assign the node to follow in this field.

## Layers

This is the parent node that hosts all the TileMapLayer nodes of the level. TileMapLayer nodes are used to draw a level using tiles.
Regarding the tileset, to facilitate the definition of Terrain Sets, the TileBitTools plugin has been added. For information on how TileBitTools works, refer to its [repository](https://github.com/dandeliondino/tile_bit_tools).

## Props

You can use this node as a parent to keep the props you add to the level organized. Props can be interactive elements or simple non-interactive decorations within the level.

## Entities

You can use this node as a parent to keep the entities you add to the level organized. Entities are the game’s characters. For more information on entities, see the Entities section.
Here you can add Marker2D nodes to indicate the spawn position of each player. The `level.gd` script will handle instantiating a player at the Marker2D position. It’s necessary to name the Marker2D nodes based on the `player_id` to associate with the player, as follows:

- P1: instantiates a player with player_id 1
- P2: instantiates a player with player_id 2
- P3: instantiates a player with player_id 3
- P4: instantiates a player with player_id 4
  and so on.

## Transfers

You can use this node as a parent to keep the transfers you add to the level organized. A Transfer allows the player to move from one level to another. For more information on transfers, see the Transfers section.

## Events

You can use this node as a parent to keep the events you add to the level organized. Events are state machines that trigger a sequence of states, useful for creating cutscenes or automated character movements. For more information on events, see the State Machine section.

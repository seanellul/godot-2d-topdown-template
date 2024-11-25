# OVERVIEW

In this section we will explore the main features that this project offers.
In general, to learn more about a specific topic, you can check "Nodes and Classes definitions" below.
You can also download and launch the project from the Godot editor (F5) to start a tutorial. The tutorial will explore some main features, giving you suggestions on how to configure the various elements that this project offers.
When you start working on your project, you can safely delete all the scenes that start with "Tutorial\_" and configure your starting level in the file `Const.gd` -> LEVEL.LEVEL_1

## Character Controller

Characters are nodes that can move and perform actions in a level, through the configuration of different states. States can be configured thanks to a StateMachine node.
States simply call methods already present in the characters.
To begin with, a character can walk, run, jump, attack, flash and interact with other elements. These features can be expanded by adding new states that call new methods that you can create for the character.
Additionally, characters have health points that can be represented by a custom HUD.
To learn more about characters, check the **Entity** section.

## Interaction

Interactions with other elements in the level, such as levers, objects, NPCs or transfers, are possible thanks to an Area2D added to the character. The interaction is managed by a state (`StateInteract`) that offers different configurations, such as:

- the interaction area (`InteractionArea2D`)
- which states to enable on interaction
- which states to enable when leaving the interaction area
- activate the interaction via the input of an action (defined in Input Map)
- restrict the interaction only in a certain direction (for example: the character must be facing upwards)
- restrict the interaction only if the character has certain items in his inventory (for example: a key)

## Inventory

The inventory manages all the items owned by a player. The project provides a simple node (`Inventory.tscn`) assigned as a child of the player, which shows all the items owned by him. You can delete this inventory and create your own according to your preferences. Press _ESC_ on your keyboard to open/close the inventory.

## Data Management (Save/Load)

The project provides a data management system. It works in a very simple way: all nodes found in the current level (scene) with the group "save" or "player" will be handled by the save/load system. This is done by the singleton `DataManager`. By default, only data from `StateMachine` and `CharacterEntity` are handled by the system. While these should cover most use cases, you can extend their functionality to your liking via the `DataManager.gd` script.

### "save" group

- StateMachine: By assigning the group "save" to a `StateMachine`, you will save the current state of the StateMachine. This is useful, for example, to handle the open/close state of chests or doors.
- CharacterEntity: By assigning the group "save" to a `CharacterEntity`, you will save the current position and facing direction of the character.

### "player" group

- Player: Player data is handled differently by the save system and it is saved/loaded without the node needing to be in the "save" group (it must be in the "player" group, though). Players have a `player_entity.gd` script that contains the `get_data` and `receive_data` methods. `get_data` tells what data to save in the save file, while `receive_data` decides what to do with the incoming data from the save file (previously saved).
  The player's data saved is:
- position
- facing direction
- current level
- max hp and current hp
- inventory
- equipped weapon id

You can extend the `PlayerEntity` class and the saved data as you like.

In all cases, the data will be saved and kept even when moving from one level to another (using a `Transfer`). The data is lost if you close the game without saving (to a file). In the project it is possible to save the data quickly thanks to the singleton `Debugger`, by pressing the _F1_ key on the keyboard.
You can also quickly load data by pressing the _F2_ key.

## States Management

State management is controlled by a `StateMachine` node. A StateMachine node, as the name suggests, is used to manage different states. All states extends from the script `state.gd` and can be added as children of a StateMachine. Each child of a StateMachine represents a single state. Furthermore, a single state can have multiple states as children. All the child states of another state will be enabled (and disabled) together with the parent state.
The state assigned to `current_state` of the StateMachine will be the first active state for that StateMachine. It is also possible to change the current state in various ways:

- by setting a timer on the single state, which when timed out activates the state defined in `on_completion`
- by waiting for the state to complete, before activating the state defined in `on_completion`. A state is "completed" when the `complete` method of `state.gd` is called.

Each state has the following flow:

- **enter**: series of commands to call when the state is enabled
- **exit**: series of commands to call when the state is disabled
- **update**: equivalent of `_process`
- **physics_update**: equivalent of `_physics_process`

The states already available in the project are the following:

- **StateAnimation**: allows you to start an animation defined in an `AnimationPlayer` or `AnimationTree`
- **StateCallable**: allows you to call a method from another node
- **StateDebug**: allows you to print a message (with `print_debug`) in the terminal. Useful for debugging purposes
- **StateDialogue**: allows you to start a dialogue defined with the plugin `DialogueManager` (check the **Dialogue System** section)
- **StateInteract**: allows you to manage interactions with something. You can assign the states to be activated "on_interaction"
- **StateMaterial**: allows you to change the material of a Sprite2D node
- **StateParamsSetter**: allows you to set a series of variables of a node when entering and when exiting a state
- **StateTween**: allows you to define and call a tween on a node
- **StateEntity**: is the base state from which all the states specific to the Entities extend. Explore the states that extend `StateEntity` to find out more.

You can also create new states, extending the base script `state.gd` or `state_entity.gd`.

### Listening for state change

A `ChangeStateListener` (`change_state_listener.gd`) is a node that, assigned as children of a node with a StateMachine, allows to listen for the change of state of the StateMachine of another node and, for each listening state, associate one to enable.
Useful for managing, for example, a lever that opens a door: the door can listen for the states of the lever and opens or closes based on the on/off state of the lever.

### Event sequences

In the StateMachine, by setting the `sequence` parameter to true, you can activate a series of states in sequence.
If necessary, remember to set the `await_completion` parameter to true inside a state and define the next state to enable in `on_completion`.
This setting is useful for creating cutscenes or managing a series of states automatically.

## Scenes Transition

Transition between scenes is managed by `SceneManager.gd` from [baconandgames](https://github.com/baconandgames). For more information check out the [official repository](https://github.com/baconandgames/godot4-game-template).

## User Prefs

User preferences (like music settings or language) are also managed by scripts from [baconandgames](https://github.com/baconandgames). For more information check out the [Godot 4 Game Template](https://github.com/baconandgames/godot4-game-template). In the project, you can access them through the `SettingsMenu` (`settings_menu.gd`).

## Dialogue System

Dialogues are managed by the plugin `DialogueManager` from [nathanhoad](https://github.com/nathanhoad). For more information check out the [official repository](https://github.com/nathanhoad/godot_dialogue_manager).

## Tilemaps

To easily manage TileMap terrains, the plugin `TileBitTools` from [dandeliondino](https://github.com/dandeliondino) has been added to the project. To find out how to set up Terrains, check out the [official repository](https://github.com/dandeliondino/tile_bit_tools).

## Debugger

Debugging is managed by the Autoload `Debugger`. Check out the `debugger.gd` script to find out what offers and add your debugging methods.

## Localization

Localization is managed by the default localization system of Godot. The project offers two already configured languages: _English_ (en) and _Italian_ (it). Check out the `local` folder to find out all the translated strings.
To manage the list of languages you can check the constant `LANGUAGES` in `Const.gd` and remove or add new languages there. Then, you have to create a corresponding `.translation` file in the `local` folder and add (or remove) it in _Project Settings -> Localization_.

# NODES AND CLASSES DEFINITIONS

## Entities

All characters in the game, including main characters, enemies, and NPCs, are defined as entities.
The base node for entities is `entity.tscn`, which has attached the script `character_entity.gd` (`CharacterEntity`).
The CharacterEntity class inherits from CharacterBody2D and it is used to control everything about the entity, including actions (movement, jumping, attack), animations, states and energy.
There are nodes that inherit from the `entity.tscn` node for a more specific usage, such as:

- `Player` (`player.tscn`), with the attached script `player_entity.gd` (`PlayerEntity`), which inherits from `CharacterEntity`
- `Enemy` (`enemy.tscn`)
  <br><br>
  Below, we explore the structure of `CharacterEntity` and its management, then move on to the specifics of the `PlayerEntity` class.

#### entity.tscn

The `entity.tscn` node is structured as follows:

- Entity (`character_entity.gd`)
  - CollisionShape2D
  - Shadow
  - AnimatedSprite2D
  - BlocksDetector
  - FallDetector
  - AnimationPlayer
  - AnimationTree

###### Entity

*CharacterEntity < CharacterBody2D* <br>
All properties and methods in the `character_entity.gd` script have comments.
You can check the comments to better understand the functionality of the script.

###### CollisionShape2D

`CollisionShape2D` used by CharacterBody2D. It provides a collider for the entity, set to level 2 (`character`), and scans all colliders on levels 1 (`block`), 2 (`character`), and 3 (`body`).

###### Shadow

`Sprite2D` that represents a shadow beneath the entity.

###### AnimatedSprite2D

The main `AnimatedSprite2D` representing the entity.

###### BlocksDetector

`RayCast2D` to identify when the entity is facing a blocking element, such as a wall or object. It scans levels 1 (`block`) and 3 (`body`). The rotation is synchronized with the direction the entity is facing, as this node is added to the `sync_rotation` array of `CharacterEntity`.

###### FallDetector

`ShapeCast2D` to identify when the entity is in an unsafe position. A safe position is one where the entity can move freely. This is useful for identifying cliffs and making the entity “fall” when over them. It scans level 3 (`body`) and triggers the `on_fall` state of `CharacterEntity` when it collides.

###### AnimationPlayer

The main `AnimationPlayer` that manages all entity animations. Animations are divided into libraries, where each library represents a specific animation (e.g., idle, jump, attack) containing 4 animations, one for each direction (down, left, right, up). For more information on animations.

###### AnimationTree

The main `AnimationTree` that manages the entity's various animations. Animations are controlled by a state machine, with each animation linked to the entity's current action (see the "Actions" group of `CharacterEntity`).

#### player.tscn

The `player.tscn` node inherits from `entity.tscn`. Here, we explore nodes that are not already present in the parent node:

- Player (`player_entity.gd`)
  - SmokeParticles
  - InteractionTrigger
  - StateMachine (`state_machine.gd`)

###### Player

*PlayerEntity < CharacterEntity* <br>
All properties and methods in the `player_entity.gd` script have comments. You can check the comments to better understand the functionality of the script.

###### SmokeParticles

`GPUParticles2D` whose emission is activated when the entity is running (see `running_particles` in `CharacterEntity`).

###### InteractionTrigger

`Area2D` defining the area that allows the entity to interact with interactive elements. Interactions can be triggered by the `StateInteract` state. For more information on states, see the **State Management** section.

###### StateMachine

`StateMachine` that controls all possible states of this entity. For more information, see the **State Management** section.

## Levels

A level is a game area where playable characters, NPCs, any enemies, and props are present. The base node for levels is `Level.tscn`, which has attached the script `level.gd`. The Level node can be used as a starting node for creating new levels. It already has a structure of nodes within it, making it fully functional. Exploring the present nodes, we find:

- GameCamera2D
- Layers
- Props
- Entities
- Transfers
- Events

#### GameCamera2D

The main `GameCamera2D` of the level. It has the script `game_camera.gd` attached, useful to define a camera's target to follow:

- `target_player_id`: you can set a value corresponding to the `player_id` of the player to follow (see PlayerEntity). Setting a value greater than 0 will search within the level for the player with the corresponding `player_id`. Setting the value to 0 will not search for any player, and only the `target` field will be checked.
- `target`: if you want the camera to follow any node (that is not a player), you can assign the node to follow in this field.

#### Layers

This is the parent node that hosts all the `TileMapLayer` nodes of the level. `TileMapLayer` nodes are used to draw a level using tiles.
Regarding the tileset, to facilitate the definition of Terrain Sets, the `TileBitTools` plugin has been added. For information on how TileBitTools works, refer to its [repository](https://github.com/dandeliondino/tile_bit_tools).

#### Props

You can use this node as a parent to keep the props you add to the level organized. Props can be interactive elements or simple non-interactive decorations in the level.

#### Entities

You can use this node as a parent to keep the entities you add to the level organized. Entities are the game’s characters. For more information on entities, see the **Entities** section.
Here you can add `Marker2D` nodes to indicate the spawn position of each player. The `level.gd` script will handle instantiating a player at the `Marker2D` position. You have to name these nodes based on the `player_id` to associate with the player, as follows:

- **P1**: instantiates a player with `player_id` 1
- **P2**: instantiates a player with `player_id` 2
- **P3**: instantiates a player with `player_id` 3
- **P4**: instantiates a player with `player_id` 4
  and so on.

#### Transfers

You can use this node as a parent to keep the transfers you add to the level organized. A Transfer allows the player to move from one level to another. For more information on transfers, see the **Transfers** section.

#### Events

You can use this node as a parent to keep the events you add to the level organized. Events are state machines that trigger a sequence of states, useful for creating cutscenes or automated character movements. For more information on events, see the **State Management** section.

## Transfers

A Transfer is a node that, upon interaction, allows a player to move to another level.
This node has simply been structured to perform the transfer:

- to a position in the same level (the current scene)
- to a position in any other level (a scene that has the `level.gd` attached and has the group "level" assigned)

Moving to another level is done by calling the `swap_scenes` method of the `SceneManager`.

A Transfer is structured like this:

- Transfer (`transfer.gd`)
  - InteractionArea2D
  - StateMachine
    - interact
    - call_transfer

### Transfer

Parent node that contains the script `transfer.gd` that performs the transfer, with the following parameters:

- `level_path`: the path of the level to transfer to. Leave empty if you want to move within the same level
- `destination_name`: the name of the node to use as a reference to set the destination position. This node should have assigned the "destination" group to work properly
- `facing`: changes the facing direction of the player, forcing it to face the direction configured here. Useful if the starting Transfer is East, so the player is facing right when interacting with it, but the destination is North, so the player will need to face down upon arriving.

### InteractionArea2D

It's a utility script that generates an `Area2D` and assigns a `CollisionShape2D` node to it, already configured to respond correctly to interactions handled by the `StateInteract` state.

### StateMachine

The `StateMachine` associated with this node, which contains the following states:

- **interact** (`StateInteract`): handles the player interaction. When the player enters the area defined by the `InteractionArea2D`, it enables the next state, namely:
- **call_transfer** (`StateCallable`): when activated, calls the `transfer` method of `transfer.gd`, which performs the player transfer.

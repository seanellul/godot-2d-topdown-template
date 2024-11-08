# CharacterEntity < CharacterBody2D
Script attached to the Entity node, which represents all the characters entities of the game.
The Entity node is used as a base to create players, enemies and any other npc.

## Properties (exported)
### Settings
- animation_tree: the AnimationTree attached to this entity, needed to manage animations.
- sync_rotation: a list of nodes that update their rotation based on the direction the entity is facing

### Movement
- max_speed: the maximum speed the entity can reach while moving
- friction: affects the time it takes for the entity to reach max_speed or to stop
- blocks_detector: a RayCast2D node to identify when the entity is in front of a tile or element that blocks it
- fall_detector: a ShapeCast2D node that identifies when the entity is falling, triggering the "on_fall" state
- running_particles: a GPUParticles2D to enable when the entity is running (is_running == true)

### Health
- max_hp: the total hp of the entity. If the entity has health_bar assigned, it is the value that corresponds to the health_bar completely full
- immortal: makes the entity undamageable. Exported for testing purposes
- immortal_while_is_hurting: makes the entity immortal while is_hurting == true
- health_bar: a PackedScene that displays the entity's HP
- damage_flash_power: the flash power that applies to all nodes found in the "flash" group in the entity

### Attack
- attack_power: the value this entity subtracts from another entity's HP when it attacks
- attack_speed: affects the cooldown time between attacks

### States
- on_attack: state to enable when this entity attacks
- on_hit: state to enable when this entity damages another entity
- on_hurt: state to enable when this entity takes damage
- on_fall: state to enable when this entity falls
- on_recovery: state to enable when this entity recovers HP
- on_death: state to enable when this entity dies (hp == 0)
- on_screen_entered: state to enable when this entity is visible on screen
- on_screen_exited: state to enable when this entity is outside the visible screen

## Properties (internal)
- hp: the entity's current hp
- input_enabled: if enabled, the entity will respond to input-listening states, such as state_interact and state_input_listener
- hp_bar: the health_bar instance, if assigned
- screen_notifier: the instance of a VisibleOnScreenNotifier2D node, automatically created to handle the on_screen_entered and on_screen_exited states in the entity
- attack_cooldown_timer: the timer that manages the cooldown time between attacks
- facing: the direction the entity is facing
- speed: the current speed of the entity
- invert_moving_direction: inverts the direction of movement. Useful for moving an entity away from the target position while moving
- safe_position: the last position of the entity that was deemed safe. It is set before a jump and is eventually reassigned to the entity by calling the return_to_safe_position method. The "state_fall" state is responsible for calling this method, so it is useful if assigned to "on_fall"
- is_moving: true if velocity is non-zero
- is_running: true if the entity is moving and speed > max_speed
- is_jumping: true during a jump. is handled by the jump() and end_jump() methods, called by the "jump" animation
- is_attacking: set to true when the entity enters the on_attack state, false when it leaves it
- is_charging: set to true when the entity is charging an attack
- is_hurting: set to true when the entity enters the on_hurt state, false when it leaves it
- is_blocked: true when blocks_detector.is_colliding()
- is_falling: set to true when the entity enters the on_fall state, false when it leaves it

## Methods

# PlayerEntity < CharacterEntity
Script attached to the "Player" node, specifically to represent the player entities of the game.
The "Player" node is used as a base to create the players.

## Properties (exported)
- on_transfer_start: state to enable when player starts transferring
- on_transfer_end: state to enable when player ends transferring

## Properties (internal)
- player_id: a unique id that is assigned to the player when created. Player 1 will have a player_id == 1 and each additional player will have an incremental id, 2, 3, 4, and so on.
- equipped: the id of the weapon equipped by the player
- inventory: the items this player has in their inventory

## Methods
# CharacterEntity < CharacterBody2D
Script collegato al nodo "Entity", che rappresenta tutte le entità characters del gioco.
Il nodo "Entity" è usato come base per creare i players, i nemici e qualsiasi altro npc.

## Properties (exported)
### Settings
- animation_tree: l'AnimationTree collegato a questa entità, necessario per gestire le animazioni.
- sync_rotation: una lista di nodi che devono aggiornare la loro rotazione in base alla direzione verso cui è rivolta l'entità

### Movement
- max_speed: la velocità massima che può raggiungere l'entità in movimento
- friction: influisce sul tempo necessario all'entità per raggiungere la max_speed o fermarsi
- blocks_detector: un nodo RayCast2D per identificare quando l'entità si trova davanti ad un tile o un elemento che lo blocca
- fall_detector: un nodo ShapeCast2D che identifica quanto l'entità sta cadendo, azionando lo stato "on_fall"
- running_particles: a GPUParticles2D da abilitare quando l'entità sta correndo (is_running == true)

### Health
- max_hp: gli hp totali dell'entità. Se l'entità ha assegnata una Health Bar, è il valore che corrisponde all'Health Bar completamente piena
- immortal: rende l'entità non danneggiabile. Utile per fini di test o per rendere l'entità immortale per un breve periodo dopo essere stata danneggiata
- immortal_while_is_hurting: rende l'entità immortale se is_hurting == true
- health_bar: una PackedScene che visualizza gli hp dell'entità
- damage_flash_power: la potenza del flash che si applica ai nodi trovati nel gruppo "flash" nell'entità

### Attack
- attack_power: il valore che questa entità sottrae agli hp di un'altra entità nel momento in cui attacca
- attack_speed: influisce sul tempo di cooldown tra un attacco e l'altro

### States
- on_attack: state to enable when this entity attacks
- on_hit: state to enable when this entity damages another entity
- on_hurt: state to enable when this entity takes damage
- on_fall: state to enable when this entity falls
- on_recovery: state to enable when this entity recovers hp
- on_death: state to enable when this entity dies (hp == 0)
- on_screen_entered: state to enable when this entity is visible on screen
- on_screen_exited: state to enable when this entity is outside the visible screen

## Properties (internal)
- hp: gli hp attuali dell'entità
- input_enabled: se abilitato, l'entità risponderà agli stati in ascolto di input, come state_interact e state_input_listener
- hp_bar: l'istanza dell'health_bar, se configurata
- screen_notifier: l'istanza di un nodo VisibleOnScreenNotifier2D, creato automaticamente per gestire gli stati on_screen_entered e on_screen_exited nell'entità
- attack_cooldown_timer: il timer che gestisce il tempo di cooldown tra un attacco e l'altro
- facing: la direzione verso cui è rivolta l'entità
- speed: la velocità attuale dell'entità, quando è in movimento
- invert_moving_direction: inverte la direzione di movimento. Utile per fare allontanare un'entità dalla posizione target in fase di movimento
- safe_position: l'ultima posizione dell'entità ritenuta sicura. Viene impostata prima di un salto e viene eventualmente riassegnata all'entità chiamando il metodo return_to_safe_position. Lo stato "state_fall" si occupa di richiamare questo metodo, quindi è utile se assegnato a "on_fall"
- is_moving: true se la velocity è diversa da zero
- is_running: true se l'entità si sta muovendo e speed > max_speed 
- is_jumping: true durante un salto. è gestito dai metodi jump() e end_jump(), chiamati dall'animazione "jump"
- is_attacking: da impostare a true quando l'entità entra in stato on_attack, false quando ne esce
- is_charging: da impostare a true quando l'entità sta caricando un attacco
- is_hurting: da impostare a true quando l'entità entra in stato on_hurt, false quando ne esce
- is_blocked: true quando blocks_detector.is_colliding()
- is_falling: da impostare a true quando l'entità entra in stato on_fall, false quando ne esce

## Methods

# PlayerEntity < CharacterEntity
Script collegato al nodo "Player", specifico per rappresentare le entità player del gioco.
Il nodo "Player" è usato come base per creare i players.

## Properties (exported)
- on_transfer_start: state to enable when player starts transfering
- on_transfer_end: state to enable when player ends transfering

## Properties (internal)
- player_id: un id univoco che viene assegnato al player in fase di creazione. Il giocatore 1 avrà un player_id == 1 ed ogni altro giocatore aggiuntivo avrà un id incrementale, 2, 3, 4 e così via.
- equipped: l'id dell'arma equipaggiata dal player
- inventory: gli oggetti che questo player ha nel suo inventario

## Methods

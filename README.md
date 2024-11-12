# Entities
Sono definite entità tutti i personaggi del gioco, dai personaggi principali, ai nemici, agli npc. Il nodo base delle entità è entity.tscn, che ha allegato lo script character_entity.gd (CharacterEntity). La classe CharacterEntity eredita da CharacterBody2D. CharacterEntity viene usata per controllare tutto dell'entità: azioni (movimento, salto, attacco), animazioni, stati ed energia.
Ci sono nodi che ereditano dal nodo entity.tscn, per una gestione più specifca e questi sono:
- player.tscn, che ha allegato lo script player_entity.gd (PlayerEntity), che eredita da CharacterEntity
- enemy.tscn
Di seguito esploriamo l'organizzazione di CharacterEntity e come viene gestita, per poi andare nello specifico della classe PlayerEntity.

## entity.tscn
Il nodo entity.tscn è strutturato nel seguente modo:
- Entity (character_entity.gd)
  - CollisionShape2D
  - Shadow
  - Sprite2D
  - BlocksDetector
  - FallDetector
  - AnimationPlayer
  - AnimationTree

### Entity
CharacterEntity < CharacterBody2D
Tutte le proprietà e i metodi dello script character_entity.gd sono commentati. Puoi controllare i commenti per capire al meglio le funzionalità dello script associato.

### CollisionShape2D
CollisionShape2D utilizzato dal CharacterBody2D. Fornisce un collider all'entità. è impostato sul livello 2 (character) e scansiona tutti i collider presenti nei livelli 1 (block), 2 (character), 3 (body).

### Shadow
Sprite2D che rappresenta un'ombra sotto l'entità.

### Sprite2D
Sprite2D principale che rappresenta l'entità.

### BlocksDetector
RayCast2D per identificare quando l'entità si trova davanti un elemento bloccante, come un muro o un oggetto. Scansiona i livelli 1 (block) e 3 (body). La rotazione è sincronizzata con la direzione in cui è rivolta l'entità, perché questo nodo è aggiunto all'array sync_rotation del CharacterEntity.

### FallDetector
ShapeCast2D per identificare quando l'entità si trova in una posizione non sicura. è definita una posizione sicura una posizione in cui l'entità può muoversi liberamente. è utile per individuare ad esempio burroni e "far cadere" l'entità quando si trova sopra di essi. Scansiona il livello 3 (body). Quando collide, scatena lo stato on_fall del CharacterEntity.

### AnimationPlayer
AnimationPlayer principale che gestisce tutte le animazioni dell'entità. Le animazioni sono suddivise in librerie, dove ogni libreria rappresenta una specifica animazione (es: idle, jump, attack) che contiene 4 animazioni, una per ogni direzione (down, left, right, up).
Per maggiori informazioni sul funzionamento delle animazioni, vedi il paragrafo Animazioni.

### AnimationTree
AnimationTree principale che gestisce le diverse animazioni dell'entità. Le animazioni sono controllate da una state machine ed ogni animazione è controllata dall'azione attuale dell'entità (vedi il gruppo "Actions" del CharacterEntity). Per maggiori informazioni sul funzionamento delle animazioni, vedi il paragrafo Animazioni.

## player.tscn
Il nodo player.tscn eredita da entity.tscn. Qui esploriamo i nodi che non sono già presenti nel nodo principale:
- Player (player_entity.gd)
  - SmokeParticles
  - InteractionTrigger
  - StateMachine (state_machine.gd)

### Player
PlayerEntity < CharacterEntity
Tutte le proprietà e i metodi dello script player_entity.gd sono commentati. Puoi controllare i commenti per capire al meglio le funzionalità dello script associato.

### SmokeParticles
GPUParticles2D la cui emissione viene attivata quando l'entità sta correndo (vedi running_particles del CharacterEntity).

### InteractionTrigger
Area2D che delimita l'area che permette all'entità di interagire con gli elementi interattivi. Le interazioni possono essere azionate dallo stato StateInteract. Per maggiori informazioni sugli stati, vedi il paragrafo State Machine.

### StateMachine
StateMachine che controlla tutti i possibili stati di questa entità. Per maggiori informazioni, vedi il paragrafo State Machine.
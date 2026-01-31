## Layers de tilemaps (mur / piques / trous)

- **Principe général (choix GGJ)**
	- On utilise **une TileMap par type de gameplay** :
		- `WallsGreen` pour les murs (layer verte).
		- `SpikesRed` pour les piques (layer rouge).
		- `HolesBlue` pour les trous (layer bleue).
	- Chaque TileMap partage la **même grille** pour que tout s’aligne visuellement.
	- On ne garde que cette approche simple pour la GGJ (pas de TileMap unique avec données custom pour l’instant).
	- Le changement de layer passe par `LevelManager` (autoload) qui émet le signal `layer_changed(layer: int)`.

- **Intégration avec l’architecture actuelle (LevelManager + BaseLevel)**
	- `autoload/level_manager.gd` contient déjà :
		- `enum Layer { MASK_OFF = 1, RED = 2, GREEN = 3, BLUE = 4 }`.
		- `var current_layer: int`.
		- `signal layer_changed(layer: int)` + `set_layer(layer: int)` qui émet le signal.
	- `scenes/levels/base_level.gd` (classe `BaseLevel`) est déjà abonné :
		- Dans `_ready()`, il connecte `LevelManager.layer_changed` à `on_layer_changed(layer: int)`.
		- `on_layer_changed` gère pour l’instant un simple tint de couleur via un `CanvasModulate` (`LayerTint`).
	- On va **étendre `BaseLevel`** pour aussi activer/désactiver les TileMaps `WallsGreen`, `SpikesRed`, `HolesBlue` en fonction de `layer`.

- **Mise en place dans l’éditeur Godot (scène de niveau)**
	- Ouvrir une scène de niveau (ex: `scenes/levels/base_level.tscn` ou un niveau qui hérite de `BaseLevel`).
	- Sous le node racine du niveau (qui a le script `BaseLevel.gd`) :
		- Ajouter une TileMap `WallsGreen` (murs, layer verte).
		- Ajouter une TileMap `SpikesRed` (piques, layer rouge).
		- Ajouter une TileMap `HolesBlue` (trous, layer bleue).
	- Pour chaque TileMap :
		- Assigner le **même Tileset** ou au moins un tileset aligné aux mêmes tailles de tiles.
		- Configurer les **collisions** dans le tileset (murs solides, piques qui font mal, trous qui peuvent être gérés par code ou par zone).
		- Placer les tuiles dans la vue 2D (murs, piques, trous) à l’endroit voulu.
	- Option simple pour les collisions :
		- Quand une TileMap est inactive pour le layer courant, on met `visible = false` et on met sa `collision_layer` (et éventuellement `collision_mask`) à `0`.
		- Quand elle est active, on remet `visible = true` + une `collision_layer` non nulle (celle utilisée par le joueur pour détecter les murs/piques/trous).

- **Logique côté BaseLevel (pseudo-code GDScript)**
	- Dans `BaseLevel.gd`, on peut ajouter des références aux TileMaps :
		- `@onready var walls_green: TileMap = $WallsGreen`
		- `@onready var spikes_red: TileMap = $SpikesRed`
		- `@onready var holes_blue: TileMap = $HolesBlue`
	- On étend `on_layer_changed(layer: int)` pour :
		- Garder le tint de couleur existant (`LayerTint`).
		- Ajouter un appel à une fonction interne (ex: `_update_tilemaps_for_layer(layer)`).
	- Cette fonction applique les règles :
		- Si `layer == LevelManager.Layer.GREEN` :
			- `WallsGreen.visible = true` et `WallsGreen.collision_layer` > 0.
			- `SpikesRed` et `HolesBlue` passent `visible = false` et `collision_layer = 0`.
		- Si `layer == LevelManager.Layer.RED` :
			- `SpikesRed.visible = true` et `SpikesRed.collision_layer` > 0.
			- `WallsGreen` et `HolesBlue` désactivées.
		- Si `layer == LevelManager.Layer.BLUE` :
			- `HolesBlue.visible = true` et `HolesBlue.collision_layer` > 0.
			- Les deux autres désactivées.
		- Si `layer == LevelManager.Layer.MASK_OFF` :
			- Tous `visible = false` et `collision_layer = 0`.

- **Interaction avec le joueur et les portails**
	- Le `player.gd` n’a pas besoin de connaître les layers :
		- Il se contente d’avoir un `collision_mask` qui inclut la layer de collision utilisée par les TileMaps actives.
		- Quand une TileMap est inactive, comme on met sa `collision_layer` à `0`, le joueur ne la "voit" plus en collision.
	- Le `portal_manager.gd` (ou les portails dans la scène) peut appeler `LevelManager.set_layer(...)` quand le joueur entre dans un portail :
		- Exemple: `LevelManager.set_layer(LevelManager.Layer.GREEN)` pour activer les murs verts.
		- Cela déclenche automatiquement `on_layer_changed` dans `BaseLevel`, qui met à jour tint + TileMaps.

- **Résumé straight forward (ce qu’on fait pour la GGJ)**
	- On **fixe le choix** : 3 TileMaps séparées (`WallsGreen`, `SpikesRed`, `HolesBlue`).
	- `LevelManager` garde la state machine de layer (enum + `current_layer` + signal `layer_changed`).
	- `BaseLevel` écoute ce signal et :
		- Change la couleur de `LayerTint` (feedback visuel global).
		- Active/désactive les TileMaps (visible + collision) en fonction de la layer courante.
	- Les portails ou les inputs joueur ne font qu’appeler `LevelManager.set_layer(...)`.
	- Aucun autre système n’a besoin de connaître les détails de quelles TileMaps sont actives.


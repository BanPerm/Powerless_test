# Présentation globale du projet

Bienvenue sur le projet ! Ce document récapitule la structure globale, la procédure pour créer et enregistrer de nouvelles salles pour le générateur procédural, ainsi que la configuration des attaques.

---

## Structure des répertoires

| Répertoire | Description |
| :--- | :--- |
| **`assets/`** | Actuellement quasi vide. Destiné au stockage des modèles 3D, shaders, textures et autres ressources brutes. |
| **`resources/`** | Stocke les *Resources* Godot. Utilisé principalement pour paramétrer les **attaques** et configurer les **salles** pour la génération procédurale. |
| **`scenes/`** | Contient l'ensemble des scènes (composants visuels, entités, salles, éléments de décor, interfaces, signaux). |
| **`scripts/`** | Contient le code source (GDScript / C#). |

---

## Comment créer de nouvelles salles

### 1. Création de la scène
1. Dans le dossier `scenes/`, faites un **Clic droit > Nouvelle Scène**.
2. Définissez le nœud racine (*Root Node*) comme un **`Node3D`**.
3. Attachez à ce nœud le script : `scripts/generation/room_instance.gd`.

### 2. Intégration des ouvertures (Portes)
- Pour ajouter une porte ou un passage, instanciez une scène enfant et recherchez la scène **`door_maker_with_plug`**.

### 3. Configuration des groupes (Navigation & Occultation)
Pour que la navigation des PNJ et le rendu fonctionnent correctement, vous devez assigner des groupes aux nœuds dans l'Inspecteur (onglet **Groupe** en haut à droite) :

- **Sol (`Floor`)** :
  - Ajoutez le nœud du sol au groupe **`nav_source`** (nécessaire pour le calcul du maillage de navigation / NavMesh).
- **Murs (`Walls`)** :
  - Ajoutez les murs au groupe **`nav_source`** (pour les obstacles de navigation).
  - Ajoutez également les murs au groupe **`occluder`** (pour la gestion de l'occlusion / culling).

### 4. Enregistrement dans le Générateur de Donjon

> ⚠️ **Important :** Ne pas mettre la scène `.tscn` dans le générateur, mais la **ressource** `RoomTemplate` associée !

1. **Créer la ressource `RoomTemplate`** :
   - Allez dans le dossier `resources/room_template/`.
   - **Clic droit > Créer une ressource** $\rightarrow$ recherchez **`RoomTemplate`**.
   - Dans l'inspecteur de cette nouvelle ressource :
     - Assignez la scène `.tscn` créée à l'étape 1.
     - Spécifiez les dimensions : $x = X$ et $y = Z$ *(Remarque : l'axe Y du monde 3D correspond à la profondeur Z de la grille 2D du générateur. Les salles en hauteur sont gérées sans problème).*

2. **Ajouter la salle au `DungeonManager`** :
   - Ouvrez la scène `scenes/levels/test_level.tscn`.
   - Sélectionnez le nœud **`DungeonManager`**.
   - Dans l'inspecteur à droite, repérez les listes de templates (`StartTemplate`, `Normal`, etc.).
   - Glissez-déposez la ressource `RoomTemplate` que vous venez de créer dans la catégorie voulue.

---

## Comment créer des attaques

Le système repose sur 4 types d'attaques principaux :
* 🧙 **`SummonAttackData`** : Attaques d'invocation.
* ⚔️ **`MeleeAttackData`** : Attaques au corps à corps.
* 🏹 **`RangedAttackData`** : Attaques à distance / projectiles.
* 💥 **`AreaAttackData`** : Attaques de zone (AoE).

### Procédure de création :
1. Rendez-vous dans le dossier **`resources/attacks/`**.
2. Faites un **Clic droit > Créer une ressource** (ou appuyez sur le raccourci `I`).
3. Choisissez le type d'attaque souhaité.
4. Ajustez les paramètres dans l'inspecteur.
5. **Configuration des effets de statut** :
   - Le paramètre clé est l'effet de l'attaque.
   - Si vous utilisez un effet prédéfini (ex: `applystatuseffect`), utilisez ou inspirez-vous des templates situés dans **`resources/status_presets/`**.
# Introduction à Git pour Godot

Git est l'outil indispensable pour gérer l'historique de son code et travailler à plusieurs. Dans le cadre d'un projet Godot, il va nous permettre de versionner tout le projet : scènes (`.tscn`), scripts (`.gd`), ressources (`.tres`), sprites, etc.

## 1. Installation de Git

1. Télécharge et installe Git depuis le site officiel : [git-scm.com/download/win](https://git-scm.com/download/win).
2. Laisse les options par défaut durant l'installation.
3. Une fois l'installation terminée, ouvre une **Invite de commandes** (`cmd`) ou **PowerShell** et tape :
   ```bash
   git --version
   ```
- Si tu obtiens un résultat du type git `version 2.x.x` : Tout est parfait !
- Si la commande n'est pas reconnue : Il faut ajouter Git aux variables d'environnement Windows :
    1. Appuie sur `Win + R`, entre `sysdm.cpl` et valide.
    2. Va dans l'onglet Paramètres système avancés > Variables d'environnement.
    3. Dans la section Variables système (en bas), sélectionne `Path` et clique sur Modifier.
    4. Clique sur Nouveau et ajoute : C:\Program Files\Git\cmd.
    5. Valide tout et redémarre ton terminal (ferme et rouvre).

## 2. Configuration initiale & Clé SSH

La clé SSH permet de sécuriser la connexion avec GitHub sans avoir à saisir son mot de passe à chaque action.

### Configuration du profil

Ouvre ton terminal et configure ton identité (remplace par tes informations GitHub) :
```bash
git config --global user.name "TonNom"
git config --global user.email "ton_email@example.com"
```

### Génération et ajout de la clé SSH

1. Génère la clé en exécutant la commande suivante (remplace par ton email GitHub) :
```bash
ssh-keygen -t ed25519 -C "ton_email@example.com"
```
>(Appuie sur Entrée à chaque question pour laisser les options par défaut).

2. Affiche et copie le contenu de ta clé publique :
```bash
type %USERPROFILE%\.ssh\id_ed25519.pub
```
>(Sélectionne le texte affiché et copie-le).

3. Ajoute la clé sur GitHub :
    - Rendez-vous sur :  [github.com/settings/keys](github.com/settings/keys)
    - Clique sur New SSH key.
    - Donne un titre (ex: PC Bureau).
    - Colle la clé dans le champ Key.
    - Clique sur Add SSH key.

## 3. Récupération du Projet (Clone)

⚠️ Avant de commencer : Donne-moi ton identifiant GitHub pour que je puisse t'ajouter aux contributeurs du dépôt !

1. Navigue jusqu'au dossier où tu souhaites stocker le projet.
2. Fais un clic droit dans le dossier > Ouvrir dans le terminal (ou cmd).
3. Clone le dépôt avec la commande :
```bash
git clone git@github.com:BanPerm/Powerless_test.git
```

Bravo, le projet est maintenant récupéré en local sur ton ordinateur ! 🎉

## 4. Routine de travail au quotidien

### Avant de commencer à travailler

Mets toujours à jour ton projet local pour récupérer les dernières modifications de l'équipe :
Voici les commandes à utiliser à chaque session de travail :
```bash
git pull
```

💡 Conseil : Si tu prévois de modifier une scène ou un script spécifique, préviens moi pour éviter de modifier le même fichier en même temps (ce qui crée des conflits, je pense pas que tu est envie de toucher à ça xD).

### Une fois tes modifications terminées

Préparer les fichiers à envoyer :
```bash
git add .
```

Créer le point de sauvegarde (commit) avec un message explicatif :
```bash
git commit -m "Ajout du saut du joueur et correction du bug de collision"
```

Envoyer les modifications en ligne :
```bash
git push
```
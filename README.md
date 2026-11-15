# nixos-base — le socle commun

NixOS + GNOME pour mes proches. Ce dépôt ne contient **rien de personnel** :
chaque personne a son propre petit dépôt (ex. [`alice`](https://github.com/Nixos-config-friends/alice)) qui importe ce socle
et fixe ses réglages via les options `relatives.*`.

## Ce que fournit le socle

| Module | Contenu |
|---|---|
| `modules/base.nix` | systemd-boot (10 versions gardées), français, clavier FR (aussi au déverrouillage du disque), NetworkManager, imprimantes, pas de SSH, comptes |
| `modules/gnome.nix` | GNOME (sans ses applis en double : GNOME Web, lecteurs vidéo et audio, « Mots de passe et clés »), Dash to Dock (toujours visible, en bas), logithèque Flatpak. Réglages posés en **valeurs par défaut** : modifiables à la souris |
| `modules/apps.nix` | Firefox (FR, DuckDuckGo par défaut, accueil sans raccourcis ni contenus sponsorisés, extensions Bitwarden et uBlock Origin, sans proposition d’enregistrer les mots de passe), LibreOffice + correcteur FR, OnlyOffice, polices compatibles Microsoft, Pinta, VLC (lecteur par défaut des vidéos et de la musique), Signal, Discord, Bitwarden, Cryptomator, RustDesk, Zoom, web-apps Photoshop / Word / Outlook / WhatsApp / Teams / Google Meet (fenêtres Chromium dédiées) |
| `modules/auto-upgrade.nix` | mise à jour quotidienne en « pull » depuis le dépôt de la personne, seulement sur secteur, ménage automatique, signal healthchecks.io |
| `modules/backup.nix` | restic quotidien chiffré (optionnel), qui n'entre jamais dans un coffre Cryptomator ouvert |
| `modules/hardware/old-mac.nix` | Wi-Fi Broadcom, ventilateurs (mbpfan), clavier Apple FR, webcam et inversion Ctrl/⌘ en option |
| `home/default.nix` | pour tous les comptes : Flathub « utilisateur », mises à jour Flatpak hebdomadaires |

## Options disponibles (dans le `personal.nix` de chacun)

```nix
relatives = {
  user = "alice";                        # obligatoire
  fullName = "Alice";
  flake = "github:Nixos-config-friends/alice";   # obligatoire
  admin = null;                          # ou "depannage" : compte admin local, sans accès distant
  gnome.buttons = "mac";                 # ou "classic"
  autoUpgrade.time = "12:30";
  autoUpgrade.pingUrlFile = "/etc/nixos-secrets/healthchecks-url";
  hardware.oldMac = { enable = true; webcam = false; swapCtrlCmd = false; };
  backup = { enable = true; repository = "sftp:…"; };
};
```

Tout ce que le socle pose en `lib.mkDefault` (fuseau, langue, disposition du clavier…)
peut être changé directement dans le `personal.nix`, sans `mkForce`.

## Mise en route

1. Le dépôt doit rester **public** : les machines le lisent sans identifiant.
2. Pousser le `flake.lock` (ou lancer l'Action « Mise à jour des dépendances » à la main,
   qui le crée et le publie si la machine de test se construit).
3. Dans *Settings → Actions → General → Workflow permissions* de l'organisation,
   choisir « Read and write » : sinon les Actions ne peuvent pas publier le `flake.lock`.
4. Tester dans une VM (marche aussi depuis Fedora, il suffit d'avoir Nix) :
   ```sh
   nix build .#nixosConfigurations.vm-test.config.system.build.vm
   ./result/bin/run-vm-test-vm      # identifiant test / mot de passe test
   ```

## Cycle de vie

- **Chaque dimanche**, l'Action `update.yml` met à jour nixpkgs / Home Manager /
  nix-flatpak, construit la VM de test et publie le `flake.lock` si tout passe.
- Les dépôts des proches récupèrent ensuite cette version avec leur propre Action
  (le lundi, dans `alice`). Si vous voulez une période d'essai sur votre propre
  machine avant eux, décalez leur Action de quelques jours.
- **Deux fois par an** (mai et novembre), changer la version dans `flake.nix`
  (`nixos-26.05` → `nixos-26.11`, `release-26.05` → `release-26.11`).
  C'est le moment délicat (nouveau GNOME, Dash to Dock parfois en retard) :
  tester avec la VM avant de pousser. Ne **pas** changer `system.stateVersion`
  ni `home.stateVersion` dans les dépôts des proches.

## Ajouter un proche

1. Copier le dépôt `alice` comme modèle (nouveau nom, nouveau `hostname`).
2. Installer NixOS sur sa machine, récupérer son `hardware-configuration.nix`.
3. Remplir son `personal.nix`, pousser, faire le premier `nixos-rebuild switch`.

Si un nouveau besoin matériel apparaît (autre modèle de portable…), l'ajouter
dans `modules/hardware/` derrière une option désactivée par défaut.

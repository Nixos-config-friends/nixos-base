# nixos-proches — le socle commun

NixOS + GNOME pour mes proches. Ce dépôt ne contient **rien de personnel** :
chaque personne a son propre petit dépôt (ex. `nixos-marie`) qui importe ce socle
et fixe ses réglages via les options `relatives.*`.

## Ce que fournit le socle

| Module | Contenu |
|---|---|
| `modules/base.nix` | systemd-boot (10 versions gardées), français, clavier FR (aussi au déverrouillage du disque), NetworkManager, imprimantes, pas de SSH, comptes |
| `modules/gnome.nix` | GNOME, Dash to Dock (toujours visible, en bas), logithèque Flatpak. Réglages posés en **valeurs par défaut** : modifiables à la souris |
| `modules/apps.nix` | Firefox (FR), LibreOffice + correcteur FR, OnlyOffice, polices compatibles Microsoft, Cryptomator, RustDesk, web-apps Photoshop / Word / Outlook (fenêtres Chromium dédiées) |
| `modules/auto-upgrade.nix` | mise à jour quotidienne en « pull » depuis le dépôt de la personne, seulement sur secteur, ménage automatique, signal healthchecks.io |
| `modules/backup.nix` | restic quotidien chiffré (optionnel), qui n'entre jamais dans un coffre Cryptomator ouvert |
| `modules/hardware/old-mac.nix` | Wi-Fi Broadcom, ventilateurs (mbpfan), clavier Apple FR, webcam et inversion Ctrl/⌘ en option |
| `home/default.nix` | pour tous les comptes : Flathub « utilisateur », mises à jour Flatpak hebdomadaires |

## Options disponibles (dans le `personal.nix` de chacun)

```nix
relatives = {
  user = "marie";                        # obligatoire
  fullName = "Marie";
  flake = "github:VOTRE-COMPTE/nixos-marie";   # obligatoire
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

1. Remplacer `VOTRE-COMPTE` dans `tests/vm-test.nix`.
2. Créer le dépôt **public** sur GitHub et pousser.
3. Générer et pousser le `flake.lock` : `nix flake lock && git add flake.lock && git commit -m "Verrouillage" && git push`.
4. Tester dans une VM :
   ```sh
   nixos-rebuild build-vm --flake .#vm-test
   ./result/bin/run-vm-test-vm      # identifiant test / mot de passe test
   ```

## Cycle de vie

- **Chaque dimanche**, l'Action `update.yml` met à jour nixpkgs / Home Manager /
  nix-flatpak, construit la VM de test et publie le `flake.lock` si tout passe.
- Les dépôts des proches récupèrent ensuite cette version avec leur propre Action
  (le lundi, dans `nixos-marie`). Si vous voulez une période d'essai sur votre propre
  machine avant eux, décalez leur Action de quelques jours.
- **Deux fois par an** (mai et novembre), changer la version dans `flake.nix`
  (`nixos-26.05` → `nixos-26.11`, `release-26.05` → `release-26.11`).
  C'est le moment délicat (nouveau GNOME, Dash to Dock parfois en retard) :
  tester avec la VM avant de pousser. Ne **pas** changer `system.stateVersion`
  ni `home.stateVersion` dans les dépôts des proches.

## Ajouter un proche

1. Copier le dépôt `nixos-marie` comme modèle (nouveau nom, nouveau `hostname`).
2. Installer NixOS sur sa machine, récupérer son `hardware-configuration.nix`.
3. Remplir son `personal.nix`, pousser, faire le premier `nixos-rebuild switch`.

Si un nouveau besoin matériel apparaît (autre modèle de portable…), l'ajouter
dans `modules/hardware/` derrière une option désactivée par défaut.

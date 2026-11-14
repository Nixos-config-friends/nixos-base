# Machine virtuelle de test du socle (jamais installée sur un vrai ordinateur).
{ lib, ... }:
{
  relatives = {
    user = "test";
    fullName = "Compte de test";
    flake = "github:VOTRE-COMPTE/nixos-proches";
    gnome.buttons = "mac";
    # On évalue aussi les modules optionnels, pour que la CI les vérifie.
    hardware.oldMac.enable = true;
    backup = {
      enable = true;
      repository = "/var/lib/backup-test";
    };
    autoUpgrade.pingUrlFile = "/etc/nixos-secrets/healthchecks-url";
  };

  # Mot de passe de test, uniquement pour la VM.
  users.users.test.initialPassword = "test";

  # Une VM ne doit pas se mettre à jour toute seule.
  system.autoUpgrade.enable = lib.mkForce false;

  nixpkgs.hostPlatform = "x86_64-linux";
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
  };

  home-manager.users.test.home.stateVersion = "26.05";
  system.stateVersion = "26.05";
}

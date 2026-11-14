# Ce que toutes les machines ont en commun, hors bureau et applis.
# Tout ce qui est en mkDefault peut être changé dans le personal.nix d'un proche.
{ config, lib, ... }:
let
  cfg = config.relatives;
in
{
  # Démarrage : systemd-boot, en gardant 10 versions dans le menu de démarrage
  # (pour pouvoir revenir en arrière sans remplir la partition /boot).
  boot.loader.systemd-boot.enable = lib.mkDefault true;
  boot.loader.systemd-boot.configurationLimit = lib.mkDefault 10;
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

  # Langue, fuseau, clavier
  i18n.defaultLocale = lib.mkDefault "fr_FR.UTF-8";
  time.timeZone = lib.mkDefault "Europe/Paris";
  services.xserver.xkb.layout = lib.mkDefault "fr";
  # Même disposition dès l'écran de déverrouillage du disque chiffré :
  # sinon le mot de passe se tape en QWERTY et le disque ne s'ouvre pas.
  console.useXkbConfig = true;

  networking.networkmanager.enable = true;

  # Imprimantes (y compris détection automatique sur le réseau)
  services.printing.enable = lib.mkDefault true;
  services.avahi = {
    enable = lib.mkDefault true;
    nssmdns4 = lib.mkDefault true;
    openFirewall = lib.mkDefault true;
  };

  # Pas de serveur SSH : personne ne se connecte à distance.
  services.openssh.enable = lib.mkDefault false;

  # Les mots de passe ne sont jamais dans le dépôt : chacun choisit le sien
  # à l'installation (ou avec passwd), et NixOS le conserve.
  users.mutableUsers = true;

  users.users = lib.mkMerge [
    {
      ${cfg.user} = {
        isNormalUser = true;
        description = cfg.fullName;
        extraGroups = [ "networkmanager" ];
      };
    }
    (lib.mkIf (cfg.admin != null) {
      ${cfg.admin} = {
        isNormalUser = true;
        description = "Dépannage";
        extraGroups = [
          "wheel"
          "networkmanager"
        ];
      };
    })
  ];

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
  };

  # Ménage : supprimer les anciennes versions de plus de 30 jours
  # (lancé après chaque mise à jour réussie, cf. auto-upgrade.nix).
  nix.gc.options = lib.mkDefault "--delete-older-than 30d";
}

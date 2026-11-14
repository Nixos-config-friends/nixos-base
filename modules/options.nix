# Les réglages que chaque proche choisit dans son propre dépôt (personal.nix).
# Le socle ne contient aucune information personnelle : tout passe par ici.
{ config, lib, ... }:
let
  inherit (lib) mkOption mkEnableOption types;
in
{
  options.relatives = {
    user = mkOption {
      type = types.str;
      example = "marie";
      description = "Identifiant du compte principal (sans droits d'administration).";
    };

    fullName = mkOption {
      type = types.str;
      default = config.relatives.user;
      defaultText = lib.literalExpression "config.relatives.user";
      example = "Marie";
      description = "Nom affiché sur l'écran de connexion.";
    };

    admin = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "depannage";
      description = ''
        Compte administrateur local facultatif, pour intervenir sur place.
        Aucun serveur SSH n'est activé : ce compte ne donne aucun accès à distance.
        Son mot de passe se choisit à l'installation (passwd), jamais dans le dépôt.
      '';
    };

    flake = mkOption {
      type = types.str;
      example = "github:votre-compte/nixos-marie";
      description = "Flake que la machine récupère pour ses mises à jour automatiques.";
    };

    gnome.buttons = mkOption {
      type = types.enum [
        "mac"
        "classic"
      ];
      default = "classic";
      description = ''
        Position des boutons de fenêtre : "mac" (fermer, réduire, agrandir à gauche)
        ou "classic" (à droite).
      '';
    };

    autoUpgrade = {
      time = mkOption {
        type = types.str;
        default = "12:30";
        description = ''
          Heure de la mise à jour quotidienne (format systemd OnCalendar).
          Plutôt en journée : un portable est souvent éteint la nuit.
          Une mise à jour manquée est rattrapée au démarrage suivant.
        '';
      };

      pingUrlFile = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "/etc/nixos-secrets/healthchecks-url";
        description = ''
          Fichier (sur la machine, hors du dépôt) contenant une URL healthchecks.io.
          Elle est appelée après chaque mise à jour réussie, et avec /fail en cas d'échec.
        '';
      };
    };

    hardware.oldMac = {
      enable = mkEnableOption "les réglages des MacBook Intel (Wi-Fi Broadcom, ventilateurs, clavier Mac)";

      webcam = mkEnableOption "le pilote de la webcam FaceTime HD (à tester sur la machine)";

      swapCtrlCmd = mkEnableOption ''
        l'inversion des touches Ctrl et ⌘, pour garder les raccourcis du Mac (⌘C, ⌘V…)
      '';
    };

    backup = {
      enable = mkEnableOption "la sauvegarde quotidienne chiffrée (restic)";

      repository = mkOption {
        type = types.str;
        example = "sftp:u123456@u123456.your-storagebox.de:/sauvegardes/macbook-marie";
        description = "Dépôt restic de destination.";
      };

      passwordFile = mkOption {
        type = types.str;
        default = "/etc/nixos-secrets/restic-password";
        description = "Fichier (sur la machine, hors du dépôt) contenant le mot de passe du dépôt restic.";
      };

      paths = mkOption {
        type = types.listOf types.str;
        default = [ "/home/${config.relatives.user}" ];
        defaultText = lib.literalExpression ''[ "/home/''${config.relatives.user}" ]'';
        description = "Dossiers sauvegardés.";
      };
    };
  };
}

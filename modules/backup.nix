# Sauvegarde quotidienne chiffrée avec restic (désactivée par défaut).
#
# Les fichiers sont chiffrés sur la machine avant l'envoi : l'hébergeur ne voit rien.
# Attention : la personne qui connaît le mot de passe du dépôt restic peut lire
# ce qui est sauvegardé. Le coffre Cryptomator, lui, est sauvegardé tel quel,
# donc chiffré une seconde fois avec un mot de passe que seul son propriétaire connaît.
{ config, lib, ... }:
let
  cfg = config.relatives.backup;
in
{
  config = lib.mkIf cfg.enable {
    services.restic.backups.main = {
      repository = cfg.repository;
      passwordFile = cfg.passwordFile;
      paths = cfg.paths;
      initialize = true;
      inhibitsSleep = true; # pas de mise en veille pendant la sauvegarde

      extraBackupArgs = [
        # Ne jamais entrer dans un coffre Cryptomator ouvert (ni une clé USB) :
        # sinon son contenu déchiffré finirait dans la sauvegarde.
        "--one-file-system"
        "--exclude-caches"
      ];
      exclude = [
        "/home/*/.local/share/Cryptomator/mnt" # double sécurité, même raison
        "/home/*/.cache"
        "/home/*/.local/share/Trash"
        "/home/*/.local/share/flatpak"
        "/home/*/.var/app/*/cache"
      ];

      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
        RandomizedDelaySec = "1h";
      };
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 5"
        "--keep-monthly 12"
      ];
    };
  };
}

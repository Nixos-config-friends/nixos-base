# Mises à jour en mode « pull » : la machine va chercher sa configuration
# sur le dépôt git de son propriétaire, la construit et l'applique.
# Personne ne se connecte à la machine.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.relatives.autoUpgrade;

  # Petit service qui prévient healthchecks.io (succès, ou /fail en cas d'échec).
  ping = suffix: {
    description = "Signal healthchecks après la mise à jour automatique";
    serviceConfig.Type = "oneshot";
    path = [ pkgs.curl ];
    script = ''
      url="$(cat ${lib.escapeShellArg cfg.pingUrlFile})"
      curl -fsS -m 10 --retry 5 -o /dev/null "$url${suffix}"
    '';
  };
in
{
  config = lib.mkMerge [
    {
      system.autoUpgrade = {
        enable = true;
        flake = "${config.relatives.flake}#${config.networking.hostName}";
        # Respecter le flake.lock du dépôt : seules les versions testées en CI arrivent ici.
        upgrade = false;
        flags = [ "--print-build-logs" ];
        dates = cfg.time;
        randomizedDelaySec = "30min";
        persistent = true; # rattrape une mise à jour manquée au démarrage suivant
        allowReboot = false; # c'est la personne qui redémarre, quand elle veut
        runGarbageCollection = true; # ménage après chaque mise à jour réussie
      };

      # Ne pas lancer de mise à jour sur batterie : elle sera faite un autre jour.
      systemd.services.nixos-upgrade.unitConfig.ConditionACPower = true;

      # Un seul build à la fois, pour ne pas figer un vieux portable.
      nix.settings.max-jobs = lib.mkDefault 1;
    }

    (lib.mkIf (cfg.pingUrlFile != null) {
      systemd.services = {
        relatives-ping-success = ping "";
        relatives-ping-failure = ping "/fail";
        nixos-upgrade = {
          onSuccess = [ "relatives-ping-success.service" ];
          onFailure = [ "relatives-ping-failure.service" ];
        };
      };
    })
  ];
}

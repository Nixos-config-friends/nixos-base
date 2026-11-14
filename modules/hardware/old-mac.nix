# Réglages pour les MacBook Intel sans puce T2 (jusqu'à 2017).
# À activer dans personal.nix : relatives.hardware.oldMac.enable = true;
{ config, lib, ... }:
let
  cfg = config.relatives.hardware.oldMac;
in
{
  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        # Wi-Fi Broadcom (BCM4360…) : pilote propriétaire « wl ».
        # Il est marqué « insecure » dans nixpkgs (non maintenu, CVE-2019-9501/9502).
        # On l'autorise par son NOM et non par sa version exacte : sinon, à la
        # prochaine version, la config ne s'évalue plus et les mises à jour s'arrêtent.
        nixpkgs.config.allowUnfree = true;
        nixpkgs.config.allowInsecurePredicate = pkg: lib.getName pkg == "broadcom-sta";
        boot.kernelModules = [ "wl" ];
        boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];
        boot.blacklistedKernelModules = [
          "b43"
          "bcma"
          "ssb"
          "brcmsmac"
          "brcmfmac"
        ];
        # Ne pas utiliser linuxPackages_latest : ce pilote externe doit être
        # adapté à chaque noyau, le noyau par défaut de la version stable est plus sûr.

        hardware.enableRedistributableFirmware = true;

        # Pilotage des ventilateurs : sans lui, les Mac chauffent sous Linux.
        services.mbpfan.enable = true;

        # Clavier Apple français
        services.xserver.xkb.variant = lib.mkDefault "mac";
      }

      (lib.mkIf cfg.webcam {
        hardware.facetimehd.enable = true;
      })

      (lib.mkIf cfg.swapCtrlCmd {
        boot.extraModprobeConfig = "options hid_apple swap_ctrl_cmd=1";
      })
    ]
  );
}

# GNOME + Dash to Dock + logithèque Flatpak.
#
# Les réglages du bureau sont posés comme VALEURS PAR DÉFAUT du système :
# chacun peut les changer à la souris, et ses changements sont conservés.
# (À l'inverse, des réglages dconf dans Home Manager seraient réimposés
#  à chaque mise à jour.)
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.relatives;
in
{
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Applis de GNOME en double avec celles du socle (modules/apps.nix) :
  environment.gnome.excludePackages = with pkgs; [
    epiphany # GNOME Web : un seul navigateur, Firefox
    showtime # lecteur vidéo : VLC à la place
    decibels # lecteur audio : VLC à la place (GNOME Musique reste, pour la bibliothèque)
    seahorse # « Mots de passe et clés » : Bitwarden à la place
  ];

  # Active aussi la logithèque GNOME (gnome-software) avec Flatpak.
  # Le dépôt Flathub est ajouté par compte utilisateur (cf. home/default.nix) :
  # chacun peut installer des applis sans mot de passe administrateur.
  services.flatpak.enable = true;

  environment.systemPackages = [ pkgs.gnomeExtensions.dash-to-dock ];

  programs.dconf.profiles.user.databases = [
    {
      settings = {
        "org/gnome/shell" = {
          enabled-extensions = [ "dash-to-dock@micxgx.gmail.com" ];
          # Applis du dock : celles de GNOME, avec Firefox à la place de GNOME Web.
          favorite-apps = [
            "firefox.desktop"
            "org.gnome.Nautilus.desktop"
            "org.gnome.Calendar.desktop"
            "org.gnome.TextEditor.desktop"
            "org.gnome.Music.desktop"
          ];
        };

        "org/gnome/shell/extensions/dash-to-dock" = {
          dock-position = "BOTTOM";
          dock-fixed = true; # toujours visible, comme sur un Mac
          extend-height = false;
          show-trash = true;
          show-mounts = true; # clés USB et disques dans le dock
          click-action = "focus-or-previews";
        };

        "org/gnome/desktop/wm/preferences" = {
          button-layout =
            if cfg.gnome.buttons == "mac" then "close,minimize,maximize:" else "appmenu:minimize,maximize,close";
        };
      };
    }
  ];
}

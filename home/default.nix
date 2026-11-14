# Module Home Manager appliqué à TOUS les comptes de TOUTES les machines.
# Rester minimal : ce qui est déclaré ici est réimposé à chaque mise à jour.
{ ... }:
{
  # Flathub au niveau du compte : la logithèque GNOME peut installer des applis
  # sans mot de passe administrateur.
  services.flatpak = {
    remotes = [
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
    ];
    # Mettre à jour les applis Flatpak une fois par semaine.
    update.auto = {
      enable = true;
      onCalendar = "weekly";
    };
    # Ne JAMAIS supprimer les applis que la personne a installées elle-même.
    uninstallUnmanaged = false;
  };
}

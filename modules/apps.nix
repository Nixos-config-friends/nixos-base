# Applis installées chez tout le monde. Les applis propres à chacun
# vont dans son personal.nix (environment.systemPackages).
{ lib, pkgs, ... }:
let
  # --- Web-apps -------------------------------------------------------------
  # Photoshop, Word et Outlook n'existent pas sous Linux : on ouvre leur
  # version web dans une fenêtre dédiée (sans barre d'adresse ni onglets),
  # lancée depuis la grille d'applis ou le dock comme une vraie appli.
  # Firefox ne sait pas faire de fenêtre « appli » sous Linux : on utilise
  # Chromium, appelé directement (il n'apparaît donc pas lui-même dans les applis).
  # Le compte Microsoft / Adobe reste connecté d'une fois sur l'autre.

  # Icône simple (carré arrondi + lettres) : pas de logo de marque à télécharger.
  mkIcon =
    id: background: textColor: letters:
    pkgs.writeText "web-app-${id}.svg" ''
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 128 128">
        <rect x="8" y="8" width="112" height="112" rx="26" fill="${background}"/>
        <text x="64" y="83" text-anchor="middle" font-family="sans-serif"
              font-size="54" font-weight="bold" fill="${textColor}">${letters}</text>
      </svg>
    '';

  mkWebApp =
    {
      id,
      name,
      description,
      url,
      icon,
    }:
    pkgs.makeDesktopItem {
      name = "web-app-${id}";
      desktopName = "Web-app ${name}";
      comment = description;
      exec = "${pkgs.chromium}/bin/chromium --app=${url}";
      icon = "${icon}";
      # Nom de fenêtre que Chromium donne à une fenêtre --app : permet au dock
      # d'afficher la bonne icône au lieu de celle de Chromium.
      # Format : chrome-<adresse sans https://, « / » remplacés par « _ »>-Default
      startupWMClass = "chrome-${lib.replaceStrings [ "/" ] [ "_" ] (lib.removePrefix "https://" url)}-Default";
      categories = [ "Network" ];
    };

  webApps = [
    (mkWebApp {
      id = "photoshop";
      name = "Photoshop";
      description = "Photoshop dans une fenêtre (abonnement Adobe nécessaire)";
      # Avec un « / » final : sinon le nom de fenêtre ne colle pas au format ci-dessus.
      url = "https://photoshop.adobe.com/";
      icon = mkIcon "photoshop" "#001e36" "#31a8ff" "Ps";
    })
    (mkWebApp {
      id = "word";
      name = "Word";
      description = "Word en ligne (compte Microsoft gratuit)";
      url = "https://www.office.com/launch/word";
      icon = mkIcon "word" "#185abd" "#ffffff" "W";
    })
    (mkWebApp {
      id = "outlook";
      name = "Outlook";
      description = "Messagerie Outlook en ligne";
      url = "https://outlook.live.com/mail/";
      icon = mkIcon "outlook" "#0078d4" "#ffffff" "O";
    })
  ];
in
{
  programs.firefox = {
    enable = true;
    languagePacks = [ "fr" ];
  };

  environment.systemPackages =
    with pkgs;
    [
      libreoffice
      hunspellDicts.fr-any # correcteur orthographique français
      onlyoffice-desktopeditors # suite bureautique à l'interface proche de Word / Excel / PowerPoint
      cryptomator # coffre-fort chiffré : le mot de passe n'est connu que de son propriétaire
      rustdesk-flutter # partage d'écran à la demande (version avec prise en charge de Wayland)
    ]
    ++ webApps;

  # Polices libres aux mêmes dimensions que celles de Microsoft : les documents
  # Word reçus gardent leur mise en page dans LibreOffice et OnlyOffice.
  fonts.packages = with pkgs; [
    liberation_ttf # Arial, Times New Roman, Courier New
    carlito # Calibri
    caladea # Cambria
  ];
}

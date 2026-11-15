# Applis installées chez tout le monde. Les applis propres à chacun
# vont dans son personal.nix (environment.systemPackages).
{ lib, pkgs, ... }:
let
  # --- Web-apps -------------------------------------------------------------
  # Photoshop, Word, Outlook, WhatsApp, Teams et Google Meet n'ont pas d'appli officielle
  # sous Linux : on ouvre leur
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
      startupWMClass = "chrome-${
        lib.replaceStrings [ "/" ] [ "_" ] (lib.removePrefix "https://" url)
      }-Default";
      categories = [ "Network" ];
    };

  # --- VLC ------------------------------------------------------------------
  # Affiché simplement « VLC » au lieu de « Lecteur multimédia VLC ».
  # On recopie le paquet avec un raccourci retouché (rien n'est recompilé) ;
  # le nom de fichier vlc.desktop ne change pas, donc les associations ci-dessous restent valables.
  vlc = pkgs.symlinkJoin {
    name = "vlc-${pkgs.vlc.version}";
    paths = [ pkgs.vlc ];
    postBuild = ''
      rm $out/share/applications/vlc.desktop
      sed -e '/^Name\[/d' -e 's/^Name=.*/Name=VLC/' \
        ${pkgs.vlc}/share/applications/vlc.desktop > $out/share/applications/vlc.desktop
    '';
  };

  # Fichiers ouverts par VLC quand on double-clique dessus.
  vlcMimeTypes = [
    # vidéos
    "video/mp4"
    "video/x-matroska"
    "video/webm"
    "video/x-msvideo"
    "video/quicktime"
    "video/x-ms-wmv"
    "video/x-flv"
    "video/mpeg"
    "video/ogg"
    "video/3gpp"
    "video/mp2t"
    "video/x-m4v"
    # musique
    "audio/mpeg"
    "audio/mp4"
    "audio/x-m4a"
    "audio/flac"
    "audio/x-flac"
    "audio/ogg"
    "audio/x-vorbis+ogg"
    "audio/opus"
    "audio/x-wav"
    "audio/x-ms-wma"
    "audio/aac"
    # listes de lecture
    "audio/x-mpegurl"
    "audio/x-scpls"
  ];

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
    (mkWebApp {
      id = "whatsapp";
      name = "WhatsApp";
      # Les notifications n'arrivent que si la fenêtre est ouverte.
      description = "WhatsApp Web (à relier au téléphone avec le QR code)";
      url = "https://web.whatsapp.com/";
      icon = mkIcon "whatsapp" "#25d366" "#ffffff" "W";
    })
    (mkWebApp {
      id = "teams";
      name = "Teams";
      # Microsoft a arrêté Teams pour Linux en 2022. Pour une simple réunion,
      # le lien reçu par e-mail s'ouvre aussi directement dans Firefox.
      description = "Microsoft Teams en ligne (réunions, discussions)";
      url = "https://teams.microsoft.com/";
      icon = mkIcon "teams" "#5059c9" "#ffffff" "T";
    })
    (mkWebApp {
      id = "meet";
      name = "Google Meet";
      # Pas besoin de compte pour rejoindre une réunion ; il en faut un pour en créer.
      description = "Visioconférence Google Meet";
      url = "https://meet.google.com/";
      icon = mkIcon "meet" "#00832d" "#ffffff" "M";
    })
  ];
in
{
  programs.firefox = {
    enable = true;
    languagePacks = [ "fr" ];
    policies = {
      # Moteur de recherche par défaut. Appliqué une seule fois : chacun peut
      # en choisir un autre dans les paramètres de Firefox, son choix est gardé.
      SearchEngines.Default = "DuckDuckGo";

      # Les mots de passe sont dans Bitwarden : Firefox ne propose plus de les
      # enregistrer lui-même (sinon deux fenêtres à chaque connexion).
      # Valeur par défaut, non verrouillée : réactivable dans
      # Paramètres → Vie privée et sécurité → Identifiants et mots de passe.
      OfferToSaveLoginsDefault = false;

      # Page d'accueil / nouvel onglet épurés : ni raccourcis, ni contenus
      # sponsorisés, ni articles recommandés. Non verrouillé : réactivable
      # dans les paramètres de Firefox (section Accueil).
      FirefoxHome = {
        TopSites = false;
        SponsoredTopSites = false;
        Stories = false;
        SponsoredStories = false;
        # Anciens noms des deux réglages ci-dessus, encore lus par Firefox.
        Pocket = false;
        SponsoredPocket = false;
      };

      # Extensions installées d'office (mises à jour par Firefox lui-même).
      # « normal_installed » : impossible de les désinstaller, mais on peut les désactiver.
      ExtensionSettings =
        let
          fromAddonsMozilla = slug: {
            installation_mode = "normal_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
            default_area = "navbar"; # icône visible dans la barre d'outils
          };
        in
        {
          # Bitwarden : remplit les mots de passe du coffre directement dans les pages.
          "{446900e4-71c2-419f-a6a7-df9c091e268b}" = fromAddonsMozilla "bitwarden-password-manager";
          # uBlock Origin : bloque publicités, pisteurs et nombreux sites piégés.
          "uBlock0@raymondhill.net" = fromAddonsMozilla "ublock-origin";
        };
    };
  };

  # VLC par défaut pour les vidéos et la musique (modifiable dans
  # Paramètres → Applications par défaut, ou avec « Ouvrir avec »).
  xdg.mime.defaultApplications = lib.genAttrs vlcMimeTypes (_: "vlc.desktop");

  environment.systemPackages =
    with pkgs;
    [
      libreoffice
      hunspellDicts.fr-any # correcteur orthographique français
      onlyoffice-desktopeditors # suite bureautique à l'interface proche de Word / Excel / PowerPoint
      pinta
      vlc # (version renommée, cf. plus haut) lit toutes les vidéos et tous les DVD, là où le lecteur de GNOME bloque parfois
      cryptomator # coffre-fort chiffré : le mot de passe n'est connu que de son propriétaire
      rustdesk-flutter # partage d'écran à la demande (version avec prise en charge de Wayland)
      signal-desktop # à relier au téléphone avec le QR code
      discord # ses mises à jour forcées sont désactivées : elles arrivent avec celles du système
      bitwarden-desktop # gestionnaire de mots de passe
      zoom-us # visioconférence Zoom (appli officielle ; le partage d'écran passe par la fenêtre de choix de GNOME)
    ]
    ++ webApps;

  # Discord et Zoom ne sont pas des logiciels libres : on les autorise par leur nom, eux seuls.
  # (Attention : définir aussi allowUnfreePredicate dans un personal.nix
  #  provoquerait un conflit ; y utiliser plutôt nixpkgs.config.allowUnfree.)
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "discord"
      "zoom" # nom du paquet zoom-us
    ];

  # Polices libres aux mêmes dimensions que celles de Microsoft : les documents
  # Word reçus gardent leur mise en page dans LibreOffice et OnlyOffice.
  fonts.packages = with pkgs; [
    liberation_ttf # Arial, Times New Roman, Courier New
    carlito # Calibri
    caladea # Cambria
  ];
}

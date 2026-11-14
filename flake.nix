{
  description = "Socle NixOS + GNOME commun à mes proches";

  inputs = {
    # Passer ces deux lignes à 26.11 dès sa sortie (fin novembre 2026) :
    #   nixos-26.05 -> nixos-26.11   et   release-26.05 -> release-26.11
    # NixOS 26.05 ne reçoit plus de correctifs après le 31 décembre 2026.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Flatpak déclaratif (Flathub « utilisateur » pour la logithèque GNOME)
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nix-flatpak,
      ...
    }:
    {
      # Tout le socle en un seul module : à utiliser via lib.mkHost.
      nixosModules.default = {
        imports = [
          ./modules
          home-manager.nixosModules.home-manager
        ];
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          # Si un fichier existe déjà, Home Manager le renomme au lieu d'échouer.
          backupFileExtension = "avant-home-manager";
          sharedModules = [
            nix-flatpak.homeManagerModules.nix-flatpak
            ./home
          ];
        };
      };

      # Construit la machine d'un proche à partir du socle.
      #   hostname : nom de la machine (doit correspondre au nom dans son flake)
      #   modules  : ses fichiers personnels (hardware-configuration.nix, personal.nix…)
      lib.mkHost =
        { hostname, modules }:
        nixpkgs.lib.nixosSystem {
          modules = [
            self.nixosModules.default
            { networking.hostName = hostname; }
          ]
          ++ modules;
        };

      # Machine de test, pour la CI et pour essayer le socle dans une VM :
      #   nixos-rebuild build-vm --flake .#vm-test && ./result/bin/run-vm-test-vm
      # (identifiant : test / mot de passe : test)
      nixosConfigurations.vm-test = self.lib.mkHost {
        hostname = "vm-test";
        modules = [ ./tests/vm-test.nix ];
      };
    };
}

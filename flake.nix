{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";

  inputs.home-manager.url = "github:nix-community/home-manager/release-22.05";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  inputs.impermanence.url = "github:nix-community/impermanence";
  inputs.impermanence.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, home-manager, nixpkgs, impermanence, ... }:

    let
      # --- Base configuration of users and systems ---

      # NixOS state version
      stateVersion = "22.05";

      # List of users, currently only "astavie"
      # Rename this user to your own username or create a new one from scratch
      users.astavie = {
        password = "";
        superuser = true;
        modules = [
          ./home/default.nix
          ./home/stumpwm.nix
          ./home/desktop.nix
          {
            programs.git = {
              userEmail = "astavie@pm.me";
              userName = "Astavie";
            };
          }
        ];
      };

      # List of systems
      # Remove all existing systems and create your own
      systems.vb = {
        inherit users;
        system = "x86_64-linux";
        id = "85dd8e44";
        modules = [
          ./hardware/uefi.nix
          ./hardware/zfs.nix
          ./system/default.nix
          ./system/vb.nix
          ./system/stumpwm.nix
        ];
      };

      # -- End of configuration --

    in
      {
        nixosConfigurations = nixpkgs.lib.mapAttrs (name: systemcfg:
          nixpkgs.lib.nixosSystem {
            inherit (systemcfg) system;

            modules = [
              impermanence.nixosModules.impermanence
              {
                system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;
                system.stateVersion = stateVersion;
                networking.hostName = name;
                networking.hostId = systemcfg.id;
              }
            ] ++ systemcfg.modules;

            specialArgs = {
              inherit (systemcfg) users;
            } // (systemcfg.specialArgs or {});
          }
        ) systems;

        homeConfigurations = nixpkgs.lib.foldr (a: b: a // b) {} (nixpkgs.lib.mapAttrsToList (name: systemcfg:
          nixpkgs.lib.mapAttrs' (username: usercfg:
            nixpkgs.lib.nameValuePair "${username}@${name}" (home-manager.lib.homeManagerConfiguration{
              inherit (systemcfg) system;
              inherit stateVersion username;
              homeDirectory = if usercfg ? home then usercfg.home else "/home/${username}";
              extraSpecialArgs = {
                inherit username;
              } // (systemcfg.specialArgs or {});
              configuration = {
                imports = [
                  impermanence.nixosModules.home-manager.impermanence
                ] ++ usercfg.modules ++ (systemcfg.sharedModules or []);
              };
            })
          ) systemcfg.users
        ) systems);
      };

}

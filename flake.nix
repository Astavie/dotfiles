{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";

  inputs.home-manager.url = "github:nix-community/home-manager/release-22.05";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  inputs.impermanence.url = "github:nix-community/impermanence";
  inputs.impermanence.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, home-manager, nixpkgs, impermanence, ... }:

    let
      util = import ./lib {};
      lib = nixpkgs.lib;

      # --- Base configuration of users and systems ---

      # NixOS state version
      stateVersion = "22.05";

      # List of users, currently only "astavie"
      # Rename this user to your own username or create a new one from scratch
      users.astavie = util.mkUser {
        username = "astavie";
        password = "";
        superuser = true;
        modules = [
          ./home/base.nix
          ./home/coding.nix
          ./home/stumpwm.nix
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
      systems = [
        (util.mkSystem {
          hostname = "vb";
          hostid = "85dd8e44";
          system = "x86_64-linux";

          users = with users; [ astavie ];
          flakedir = "${users.astavie.dir.data}/dotfiles";

          modules = [
            ./hardware/uefi.nix
            ./hardware/zfs.nix
            ./system/base.nix
            ./system/vb.nix
            ./system/xserver.nix
          ];

          sharedModules = [
            impermanence.nixosModules.home-manager.impermanence
          ];
        })
      ];

      # -- End of configuration --

    in
      {
        nixosConfigurations = builtins.listToAttrs (builtins.map (systemcfg:
          lib.nameValuePair systemcfg.hostname (lib.nixosSystem {
            inherit (systemcfg) system;

            modules = [{
              system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;
              system.stateVersion = stateVersion;
              networking.hostName = systemcfg.hostname;
              networking.hostId = systemcfg.hostid;
            }] ++ systemcfg.modules;

            specialArgs = {
              inherit (systemcfg) users flakedir hostname;
            } // systemcfg.specialArgs;
          })
        ) systems);

        homeConfigurations = lib.foldr (a: b: a // b) {} (builtins.map (systemcfg:
          builtins.listToAttrs (builtins.map (usercfg:
            lib.nameValuePair "${usercfg.username}@${systemcfg.hostname}" (home-manager.lib.homeManagerConfiguration {
              inherit (systemcfg) system;
              inherit (usercfg) username;
              inherit stateVersion;
              homeDirectory = usercfg.dir.home;

              extraSpecialArgs = {
                inherit (usercfg) username dir;
              } // usercfg.specialArgs;

              configuration = {
                imports = usercfg.modules ++ systemcfg.sharedModules;
              };
            })
          ) systemcfg.users)
        ) systems);
      };

}

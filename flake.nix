{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";

  inputs.home-manager.url = "github:nix-community/home-manager/release-22.05";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  inputs.impermanence.url = "github:nix-community/impermanence";
  inputs.impermanence.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, home-manager, nixpkgs, impermanence, ... }:

    let
      lib = nixpkgs.lib;
    in
      rec {
        dotfileSystems = builtins.mapAttrs (_: rawsystem:
          lib.evalModules {
            modules = [
              ./modules/config
              rawsystem
            ];
          }
        ) (import ./config.nix);

        nixosConfigurations = builtins.mapAttrs (_: module: let systemcfg = module.config; in lib.nixosSystem {
          inherit (systemcfg) system;

          modules = [
            ./modules/system/postinstall.nix
            {
              system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;
              system.stateVersion = systemcfg.stateVersion;
              networking.hostName = systemcfg.hostname;
              networking.hostId = systemcfg.hostid;
            }
          ] ++ systemcfg.modules;

          specialArgs = {
            inherit (systemcfg) users hostname;
          } // systemcfg.specialArgs;
        }) dotfileSystems;

        homeConfigurations = lib.foldr (a: b: a // b) {} (lib.mapAttrsToList (_: module: let systemcfg = module.config; in
          builtins.listToAttrs (builtins.map (usercfg:
            lib.nameValuePair "${usercfg.username}@${systemcfg.hostname}" (home-manager.lib.homeManagerConfiguration {
              inherit (systemcfg) system stateVersion;
              inherit (usercfg) username;
              homeDirectory = usercfg.dir.home;

              extraSpecialArgs = {
                inherit (usercfg) username dir;
              } // usercfg.specialArgs;

              configuration = {
                imports = (if systemcfg.impermanence then [ impermanence.nixosModules.home-manager.impermanence ] else [])
                  ++ systemcfg.sharedModules
                  ++ usercfg.modules;
              };
            })
          ) systemcfg.users)
        ) dotfileSystems);
      };

}

{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";

  inputs.home-manager.url = "github:nix-community/home-manager/release-22.05";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  inputs.impermanence.url = "github:nix-community/impermanence";
  inputs.impermanence.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, home-manager, nixpkgs, impermanence, ... }:

    with nixpkgs.lib;
    let
      flake = self;
      args = {
        inherit flake home-manager impermanence;
      };
    in
      rec {
        dotfileSystems = builtins.mapAttrs (_: rawsystem:
          (evalModules {
            modules = [
              { _module.args = args; }
              ./modules/config
              ./modules/config/impermanence.nix
              rawsystem
            ];
          }).config
        ) (import ./config.nix);

        nixosConfigurations = builtins.mapAttrs (_: systemcfg: systemcfg.nixos) dotfileSystems;

        homeConfigurations = foldr (a: b: a // b) {} (mapAttrsToList (_: systemcfg:
          builtins.listToAttrs (builtins.map (usercfg:
            nameValuePair "${usercfg.username}@${systemcfg.hostname}" usercfg.hm
          ) systemcfg.users)
        ) dotfileSystems);
      };

}

{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";

  inputs.home-manager.url = "github:nix-community/home-manager/release-22.05";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  inputs.impermanence.url = "github:nix-community/impermanence";
  inputs.impermanence.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, home-manager, nixpkgs, impermanence, ... }:

    with nixpkgs.lib;
    let
      args = {
        flake = self;
        inherit home-manager impermanence;
      };
      config = (evalModules {
        modules = [
          { _module.args = args; }
          ./modules/config
          ./modules/config/impermanence.nix
          ./config.nix
        ];
      }).config;
    in
      {
        inherit config;

        nixosConfigurations = builtins.listToAttrs (mapAttrsToList (name: systemcfg:
          nameValuePair name systemcfg.nixos
        ) config.systems);

        homeConfigurations = foldr (a: b: a // b) {} (mapAttrsToList (name: systemcfg:
          builtins.listToAttrs (builtins.map (usercfg:
            nameValuePair "${usercfg.username}@${name}" usercfg.hm
          ) systemcfg.users)
        ) config.systems);
      };

}

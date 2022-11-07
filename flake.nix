{
  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-22.05;

  inputs.nur.url = github:nix-community/NUR;
  inputs.nur.inputs.nixpkgs.follows = "nixpkgs";

  inputs.home-manager.url = github:nix-community/home-manager/release-22.05;
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  inputs.impermanence.url = github:nix-community/impermanence;
  inputs.impermanence.inputs.nixpkgs.follows = "nixpkgs";

  inputs.unstable.url = github:nixos/nixpkgs/nixos-unstable;

  inputs.zsh-auto-notify.url = github:MichaelAquilina/zsh-auto-notify;
  inputs.zsh-auto-notify.flake = false;

  outputs = { self, home-manager, nixpkgs, impermanence, nur, unstable, zsh-auto-notify, ... }:

    with nixpkgs.lib;
    let
      args = {
        flake = self;
        inherit home-manager impermanence nur unstable;
        inputs = {
          inherit zsh-auto-notify;
        };
      };
      config = (evalModules {
        modules = [
          { _module.args = args; }
          ./modules/config
          ./modules/config/impermanence.nix
          ./modules/config/postinstall.nix
          ./config.nix
        ];
      }).config;
    in
      {
        inherit config;

        nixosConfigurations = builtins.listToAttrs (mapAttrsToList (hostname: systemcfg:
          nameValuePair hostname systemcfg.nixos
        ) config.systems);

        homeConfigurations = foldr (a: b: a // b) {} (mapAttrsToList (hostname: systemcfg:
          mapAttrs' (username: usercfg:
            nameValuePair "${username}@${hostname}" usercfg.hm
          ) systemcfg.users
        ) config.systems);
      };

}

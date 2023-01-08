{
  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-22.11;

  inputs.home-manager.url = github:nix-community/home-manager/release-22.11;
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  inputs.impermanence.url = github:nix-community/impermanence;
  inputs.nur.url = github:nix-community/NUR;
  inputs.unstable.url = github:nixos/nixpkgs/nixos-unstable;

  inputs.zsh-auto-notify.url = github:MichaelAquilina/zsh-auto-notify;
  inputs.zsh-auto-notify.flake = false;

  inputs.android-nixpkgs.url = github:tadfisher/android-nixpkgs;
  inputs.android-nixpkgs.inputs.nixpkgs.follows = "nixpkgs";

  inputs.astapkgs.url = github:Astavie/astapkgs;
  inputs.astapkgs.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, home-manager, nixpkgs, impermanence, nur, unstable, zsh-auto-notify, android-nixpkgs, astapkgs, ... }:

    with nixpkgs.lib;
    let
      args = {
        flake = self;
        overlays = [
          astapkgs.overlays.default
          android-nixpkgs.overlays.default
        ];
        inherit home-manager impermanence nur unstable nixpkgs;
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

{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;

    home-manager.url = github:nix-community/home-manager/master;
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    impermanence.url = github:nix-community/impermanence;
    nur.url = github:nix-community/NUR;

    zsh-auto-notify.url = github:MichaelAquilina/zsh-auto-notify;
    zsh-auto-notify.flake = false;

    fenix.url = github:nix-community/fenix;
    fenix.inputs.nixpkgs.follows = "nixpkgs";

    # ---- OVERLAYS ----
    overlay-android = {
      url = github:tadfisher/android-nixpkgs;
      inputs.nixpkgs.follows = "nixpkgs";
    };

    overlay-astapkgs = {
      url = github:Astavie/astapkgs;
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.fenix.follows = "fenix";
    };

    overlay-stardust-xr-server = {
      url = github:StardustXR/server;
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.fenix.follows = "fenix";
    };

    overlay-stardust-xr-flatland = {
      url = github:StardustXR/flatland;
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.fenix.follows = "fenix";
    };
  };

  outputs = { self, home-manager, nixpkgs, impermanence, nur, zsh-auto-notify, fenix, ... }@urls:

    with nixpkgs.lib;
    let
      overlay-names = builtins.filter (hasPrefix "overlay-") (mapAttrsToList (name: _: name) urls);
      overlays = builtins.map (name: urls.${name}.overlays.default) overlay-names;

      args = {
        flake = self;
        overlays = overlays ++ [
          fenix.overlays.default
          nur.overlay
        ];
        inherit home-manager impermanence nixpkgs;
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

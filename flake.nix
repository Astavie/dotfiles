{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    impermanence.url = "github:nix-community/impermanence";
    nur.url = "github:nix-community/NUR";

    musnix.url = "github:musnix/musnix";
    musnix.inputs.nixpkgs.follows = "nixpkgs";

    # ---- OVERLAYS ----
    overlay-android = {
      url = "github:tadfisher/android-nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    overlay-astapkgs = {
      url = "github:Astavie/astapkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, home-manager, nixpkgs, impermanence, nur, musnix, ... }@urls:

    with nixpkgs.lib;
    let
      overlay-names = builtins.filter (hasPrefix "overlay-") (mapAttrsToList (name: _: name) urls);
      overlays = builtins.map (name: urls.${name}.overlays.default) overlay-names;

      args = {
        flake = self;
        overlays = overlays ++ [
          nur.overlay
        ];
        inherit home-manager impermanence nixpkgs musnix;
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

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
    overlay-astapkgs = {
      url = "github:Astavie/astapkgs";
    };
  };

  outputs = { self, home-manager, nixpkgs, impermanence, nur, musnix, ... }@urls:

    with nixpkgs.lib;
    let
      systems = [
        ./system/terrestrial.nix
        ./system/satellite.nix
        ./system/vb.nix
      ];
      modules = [
        ./config/hardware.nix
        ./config/users.nix
        ./config/impermanence.nix
        ./config/postinstall.nix
        ./config/services.nix

        ./config/ssh.nix
        ./config/steam.nix
        ./config/vbhost.nix
        ./config/docker.nix
        ./config/xserver.nix
        ./config/pipewire.nix
        ./config/hyprland.nix
        ./config/wireshark.nix
      ];

      overlay-names = builtins.filter (hasPrefix "overlay-") (mapAttrsToList (name: _: name) urls);
      overlays = builtins.map (name: urls.${name}.overlays.default) overlay-names;

      configs = builtins.map (config: (evalModules {
        modules = [
          ({ config, ... }: {
            _module.args = {
              flake = self;
              overlays = overlays ++ [ nur.overlay ];
              inherit home-manager impermanence nixpkgs musnix;
              inherit (config.nixos) pkgs;
            };
          })
          ./config
          config
        ] ++ modules;
      }).config) systems;
    in
      {
        nixosConfigurations = builtins.listToAttrs (builtins.map (systemcfg:
          nameValuePair systemcfg.hostname systemcfg.nixos
        ) configs);
      };

}

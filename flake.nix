{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    impermanence.url = "github:nix-community/impermanence";

    musnix.url = "github:musnix/musnix";
    musnix.inputs.nixpkgs.follows = "nixpkgs";

    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";

    wezterm.url = "github:wez/wezterm?dir=nix";
    wezterm.inputs.nixpkgs.follows = "nixpkgs";

    hyprland.url = "github:hyprwm/Hyprland";
    hyprland.inputs.nixpkgs.follows = "nixpkgs-unstable";

    hyprland-plugins.url = "github:hyprwm/hyprland-plugins";
    hyprland-plugins.inputs.hyprland.follows = "hyprland";

    cros.url = "github:ninelore/flake";
    cros.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # ---- OVERLAYS ----
    # overlay-astapkgs = {
    #   url = "github:Astavie/astapkgs";
    # };
  };

  outputs = { nixpkgs, ... }@inputs:

    let
      lib = nixpkgs.lib.extend (self: super: {
        subset = module: super.mkOption {
          type = with lib.types; attrsOf (submodule module);
        };
        enabled = name: users: super.filterAttrs (_: cfg: cfg.${name}.enable) users;
        module = config: name: home: system: {
          options.asta.users = self.subset (user: {
            options.${name}.enable = super.mkEnableOption name;
            config = super.mkIf user.config.${name}.enable { modules = [home]; };
          });
          config = super.mkIf (self.enabled name config.asta.users != {}) system;
        };
      });
    in
    {
      nixosConfigurations = {
        terrestrial = lib.nixosSystem {
          modules = [ ./hosts/terrestrial.nix ];
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
          };
        };
        satellite = lib.nixosSystem {
          modules = [ ./hosts/satellite.nix ];
          system = "aarch64-linux";
          specialArgs = {
            inherit inputs;
          };
        };
      };
    };

}

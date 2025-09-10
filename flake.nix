{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    impermanence.url = "github:nix-community/impermanence";

    musnix.url = "github:musnix/musnix";
    musnix.inputs.nixpkgs.follows = "nixpkgs";

    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";

    wezterm.url = "github:wez/wezterm?dir=nix";
    wezterm.inputs.nixpkgs.follows = "nixpkgs";

    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    cros.url = "github:ninelore/flake";

    # ---- OVERLAYS ----
    overlay-astapkgs = {
      url = "github:Astavie/astapkgs";
    };
  };

  outputs = { nixpkgs, ... }@inputs:

    {
      nixosConfigurations = {
        terrestrial = nixpkgs.lib.nixosSystem {
          modules = [ ./hosts/terrestrial.nix ];
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
          };
        };
        satellite = nixpkgs.lib.nixosSystem {
          modules = [ ./hosts/satellite.nix ];
          system = "aarch64-linux";
          specialArgs = {
            inherit inputs;
          };
        };
      };
    };

}

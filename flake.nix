{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    impermanence.url = "github:nix-community/impermanence";

    musnix.url = "github:musnix/musnix";
    musnix.inputs.nixpkgs.follows = "nixpkgs";

    zen-browser.url = "github:MarceColl/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";

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
      };
    };

}

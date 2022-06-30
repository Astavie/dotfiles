{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";

  inputs.home-manager.url = "github:rycee/home-manager/release-22.05";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, home-manager, nixpkgs, ... }:
  
    let
      username = "astavie";

      stateVersion = "22.05";

      mkHome = { name, system, modules }:
      {
        homeConfigurations = {
          "${name}" = home-manager.lib.homeManagerConfiguration {
            username = name;
            homeDirectory = "/home/${name}";
            inherit system;
            inherit stateVersion;
            configuration = { ... }: { imports = modules; };
          };
        };
      };

      mkSystem = { name, system, modules, args ? {} }:
      {
        nixosConfigurations = {
          "${name}" = nixpkgs.lib.nixosSystem {
            inherit system;
            inherit modules;
            specialArgs = {
              inherit username;
              inherit stateVersion;
              inherit self;
              flakeDir = null;
            } // args;
          };
        };
      };

    in
      mkHome {
        name = username;
        system = "x86_64-linux";

        modules = [
          ./home/default.nix
          ./home/vb.nix
        ];
      } //
      mkSystem {
        name = "nixos";
        system = "x86_64-linux";

        args.flakeDir = "/media/sf_dotfiles";

        modules = [
          ./hardware/vb_demo.nix
          ./system/default.nix
          ./system/vb.nix
        ];
      };

}

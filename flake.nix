{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";

  inputs.home-manager.url = "github:rycee/home-manager/release-22.05";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, home-manager, nixpkgs, ... }:

    let
      stateVersion = "22.05";

      users.astavie = {
        password = "";
        superuser = true;
        modules = [
          ./home/default.nix
          {
            programs.git = {
              userEmail = "astavie@pm.me";
              userName = "Astavie";
            };
          }
        ];
      };

      mkSystem = { users, name, system, modules, extraHomeModules ? [], specialArgs ? {} }:
      {
        nixosConfigurations = {
          "${name}" = nixpkgs.lib.nixosSystem {
            inherit system;

            modules = [{
              system.configurationRevision = nixpkgs.lib.mkIf (self ? rev) self.rev;
              system.stateVersion = stateVersion;
            }] ++ modules;

            specialArgs = {
              inherit users;
              flakeDir = null;
            } // specialArgs;
          };
        };

        homeConfigurations = nixpkgs.lib.mapAttrs' (username: usercfg:
          nixpkgs.lib.nameValuePair "${username}@${name}" (home-manager.lib.homeManagerConfiguration{
            inherit system;
            inherit stateVersion;
            inherit username;
            homeDirectory = if usercfg ? home then usercfg.home else "/home/${username}";
            extraSpecialArgs = specialArgs;
            configuration = { ... }: { imports = usercfg.modules ++ extraHomeModules; };
          })
        ) users;
      };

    in
      mkSystem {
        inherit users;

        name = "nixos";
        system = "x86_64-linux";

        # specialArgs.flakeDir = "/media/sf_dotfiles";

        modules = [
          ./hardware/vb_demo.nix
          ./system/default.nix
          ./system/vb.nix
        ];

        extraHomeModules = [
          ./home/vb.nix
        ];
      };

}

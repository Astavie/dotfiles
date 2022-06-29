{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";

  outputs = { self, nixpkgs }: {

    nixosConfigurations = {

      terrestrial = nixpkgs.lib.nixosSystem {

        system = "x86_64-linux";
        modules = [
          ./configuration.nix
        ];

        # Let 'nixos-version --json' know about the Git revision
        # of this flake.
        system.configurationRevision = with inputs; lib.mkIf (self ? rev) self.rev;
        system.stateVersion = "22.05";

      };
    };

  };
}

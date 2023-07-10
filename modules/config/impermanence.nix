{ lib, impermanence, ... }:

with lib;
let
  subset = module: mkOption {
    type = with types; attrsOf (submodule module);
  };
in
{
  options.systems = subset ({ config, ... }: {
    options = {
      impermanence.enable = mkEnableOption "impermanence";

      impermanence.dir = mkOption {
        type = types.path;
        apply = toString;
        default = "/persist/root";
        description = ''
          The persist directory of the system environment.
        '';
      };

      users = subset ({ name, ... }@u: {
        options = {
          dir.persist = mkOption {
            type = types.path;
            apply = toString;
            description = ''
              The persist directory of the user.
            '';
          };
        };
        config = {
          dir.persist = mkDefault "/persist/${name}";
          dir.config = mkIf config.impermanence.enable (dir: "${u.config.dir.persist}/${dir}");
        };
      });
    };
    config = {
      specialArgs = {
        impermanence.dir = config.impermanence.dir;
      };
      modules = mkIf config.impermanence.enable [
        impermanence.nixosModule
        (s: {
          programs.fuse.userAllowOther = true;
          environment.persistence."${config.impermanence.dir}" = {
            inherit (s.config.backup) files directories;
          };
        })
      ];
      sharedModules = mkIf config.impermanence.enable [
        impermanence.nixosModules.home-manager.impermanence
        (h: {
          home.persistence."${h.dir.persist}" = {
            removePrefixDirectory = true;
            allowOther = true;
            inherit (h.config.backup) files directories;
          };
        })
      ];
    };
  });
}

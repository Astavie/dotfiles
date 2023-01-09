{ lib, config, impermanence, ... }:

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
      modules = mkIf config.impermanence.enable [{
        programs.fuse.userAllowOther = true;
      }];
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

{ lib, config, impermanence, ... }:

with lib;
{
  options = {
    impermanence.enable = mkEnableOption "impermanence";

    users = mkOption {
      type = with types; listOf (submodule (u: {
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
            dir.persist = mkDefault "/persist/${u.config.username}";
            dir.config = mkIf config.impermanence.enable (dir: "${u.config.dir.persist}/${dir}");
          };
      }));
    };
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
}

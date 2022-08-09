{ lib, config, impermanence, ... }:

with lib;
let
  sublist = f: module: mkOption {
    type = with types; f (submodule module);
  };
in
{
  options.systems = sublist types.attrsOf ({ config, ... }: {
    options = {
      impermanence.enable = mkEnableOption "impermanence";

      users = sublist types.listOf (u: {
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

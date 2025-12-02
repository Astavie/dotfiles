{ lib, inputs, config, ... }:

{
  imports = [ inputs.impermanence.nixosModule ];

  options.asta = {
    impermanence.enable = lib.mkEnableOption "impermanence";
    impermanence.dir = lib.mkOption {
      type = lib.types.path;
      apply = toString;
      default = "/persist/root";
      description = ''
        The persist directory of the system environment.
      '';
    };
    users = lib.subset ({ name, ...}@u: {
      options = {
        dir.persist = lib.mkOption {
          type = lib.types.path;
          apply = toString;
          default = "/persist/${name}";
          description = ''
            The persist directory of the user.
          '';
        };
      };
      config = lib.mkIf config.asta.impermanence.enable {
        dir.config = (dir: "${u.config.dir.persist}/${dir}");
        modules = [
          inputs.impermanence.nixosModules.home-manager.impermanence
          (h: {
            home.persistence."${u.config.dir.persist}" = {
              removePrefixDirectory = true;
              allowOther = true;
              inherit (h.config.asta.backup) files directories;
            };
          })
        ];
      };
    });
  };

  config = lib.mkIf config.asta.impermanence.enable {
    programs.fuse.userAllowOther = true;
    environment.persistence."${config.asta.impermanence.dir}" = {
      inherit (config.asta.backup) files directories;
    };

    # zfs rollback
    boot.initrd.postResumeCommands = lib.mkAfter ''
      zfs rollback -r nixos/local/root@blank
    '';
  };
}

{ lib, config, ... }:

with lib;
{
  options = {
    # Required options
    hostname = mkOption {
      type = types.str;
      description = ''
        The hostname of the system.
      '';
    };
    hostid = mkOption {
      type = types.str;
      description = ''
        The hostid of the system.
      '';
    };
    system = mkOption {
      type = types.str;
      description = ''
        The architecture of the system.
      '';
    };
    modules = mkOption {
      type = with types; listOf raw;
      description = ''
        The modules of the system.
      '';
    };
    stateVersion = mkOption {
      type = types.str;
      description = ''
        The state version of the system.
      '';
    };

    users = mkOption {
      type = with types; listOf (submodule ({ config, ... }: {
        options = {
          # Required options
          username = mkOption {
            type = types.str;
            description = ''
              The username of the user.
            '';
          };
          modules = mkOption {
            type = with types; listOf raw;
            description = ''
              The modules of the user.
            '';
          };

          # Optional options
          superuser = mkOption {
            type = types.bool;
            default = false;
            description = ''
              Whether the user is a superuser.
            '';
          };
          specialArgs = mkOption {
            type = types.attrs;
            default = {};
            description = ''
              The special arguments to pass to the system and user modules.
            '';
          };
          
          dir.home = mkOption {
            type = types.path;
            apply = toString;
            description = ''
              The home directory of the user.
            '';
          };
          dir.data = mkOption {
            type = types.path;
            apply = toString;
            description = ''
              The data directory of the user.
            '';
          };
          dir.persist = mkOption {
            type = types.path;
            apply = toString;
            description = ''
              The persist directory of the user.
            '';
          };
        };
        config = {
          dir.home = "/home/${config.username}";
          dir.data = "/data/${config.username}";
          dir.persist = "/persist/${config.username}";
        };
      }));
      description = ''
        The users of the system.
      '';
      apply = (users: builtins.map (usercfg: {
        inherit (usercfg) username modules superuser specialArgs;
        dir = rec {
          inherit (usercfg.dir) home data;
          persist = if config.impermanence then usercfg.dir.persist else usercfg.dir.home;
          persistDir = if home == persist then (_: home) else (dir: "${persist}/${dir}");
        };
      }) users);
    };

    # Optional options
    impermanence = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to support impermanence.
      '';
    };
    specialArgs = mkOption {
      type = types.attrs;
      default = {};
      description = ''
        The special arguments to pass to the system modules.
      '';
    };
    sharedModules = mkOption {
      type = with types; listOf raw;
      default = [];
      description = ''
        The shared modules to pass to each system user.
      '';
    };
  };
}

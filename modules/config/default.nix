{ lib, config, flake, home-manager, ... }:

with lib;
let system =
  { config, ... }:
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
        type = with types; listOf (submodule (u: {
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
            dir.config = mkOption {
              type = with types; functionTo path;
              apply = (f: (x: toString (f x)));
              description = ''
                A directory to place configuration files of a specific package.
              '';
            };

            # Constants
            hm = mkOption {
              type = types.raw;
              readOnly = true;
              description = ''
                The home manager config of this module.
              '';
            };
          };
          config = {
            dir.home = mkDefault "/home/${u.config.username}";
            dir.data = mkDefault "/data/${u.config.username}";
            dir.config = mkDefault (_: u.config.dir.home);

            specialArgs = {
              inherit (u.config) username dir;
            };

            hm = home-manager.lib.homeManagerConfiguration {
              inherit (config) system stateVersion;
              inherit (u.config) username;

              homeDirectory = u.config.dir.home;
              extraSpecialArgs =  u.config.specialArgs;

              configuration = {
                imports =
                  config.sharedModules ++
                  u.config.modules;
              };
            };
          };
        }));
        description = ''
          The users of the system.
        '';
      };

      # Optional options
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

      # Constants
      nixos = mkOption {
        type = types.raw;
        readOnly = true;
        description = ''
          The NixOS system of this module.
        '';
      };
    };
    config = {
      modules = [
        ../system/postinstall.nix
        ({ lib, ... }: with lib; {
          system.configurationRevision = mkIf (flake ? rev) flake.rev;
          system.stateVersion = config.stateVersion;
          networking.hostName = config.hostname;
          networking.hostId = config.hostid;
        })
      ];

      sharedModules = [
        ({ lib, ... }: with lib; {
          options.backup.files = mkOption {
            type = with types; listOf str;
            default = [];
            description = ''
              The files inside home to backup.
            '';
          };
          options.backup.directories = mkOption {
            type = with types; listOf str;
            default = [];
            description = ''
              The directories inside home to backup.
            '';
          };
        })
      ];

      specialArgs = {
        inherit (config) users hostname;
      };

      nixos = nixosSystem {
        inherit (config) system modules specialArgs;
      };
    };
  };
in
  {
    options = {
      systems = mkOption {
        type = with types; attrsOf (submodule system);
        description = ''
          The systems.
        '';
      };
      list = mkOption {
        type = types.str;
        description = ''
          A readable list of the systems.
        '';
        readOnly = true;
      };
    };
    config = {
      list = builtins.concatStringsSep " " (builtins.attrNames config.systems);
    };
  }
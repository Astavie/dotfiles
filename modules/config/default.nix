{ lib, config, flake, home-manager, nur, unstable, inputs, ... }:

with lib;
let
  allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) (import ../../unfree.nix);
  nospace  = str: filter (c: c == " ") (stringToCharacters str) == [];
  timezone = types.nullOr (types.addCheck types.str nospace)
    // { description = "null or string without spaces"; };
  system =
  { config, name, ... }:
  {
    options = {
      # Required options
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
        type = with types; attrsOf (submodule ({ name, ... }@u: {
          options = {
            # Required options
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
            packages = mkOption {
              type = types.functionTo (types.listOf types.package);
              default = _: [];
              description = ''
                Extra packages to install for the user.
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
            dir.home = mkDefault "/home/${name}";
            dir.data = mkDefault "/data/${name}";
            dir.config = mkDefault (_: u.config.dir.home);

            specialArgs = {
              inherit (u.config) dir;
              inherit inputs;
              username = name;
            };

            hm = home-manager.lib.homeManagerConfiguration {
              inherit (config) system stateVersion;
              username = name;

              homeDirectory = u.config.dir.home;
              extraSpecialArgs = u.config.specialArgs;

              configuration = { pkgs, ...}: {
                imports =
                  config.sharedModules ++
                  u.config.modules;

                home.packages = u.config.packages pkgs;
              };
            };
          };
        }));
        description = ''
          The users of the system.
        '';
      };

      # Optional options
      timeZone = mkOption {
        type = timezone;
        default = "Europe/Amsterdam";
        example = "America/New_York";
        description = ''
          The time zone used when displaying times and dates. See <link
          xlink:href="https://en.wikipedia.org/wiki/List_of_tz_database_time_zones"/>
          for a comprehensive list of possible values for this setting.
          If null, the timezone will default to UTC and can be set imperatively
          using timedatectl.
        '';
      };
      keyMap = mkOption {
        type = with types; either str path;
        default = "us";
        example = "fr";
        description = ''
          The keyboard mapping table for the virtual consoles.
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
        ({ lib, pkgs, ... }: with lib; {
          nixpkgs.overlays = [(final: prev: {
            unstable = import unstable {
              inherit (final) system;
              config = { inherit allowUnfreePredicate; };
            };
          })];
          nixpkgs.config = { inherit allowUnfreePredicate; };
          system.configurationRevision = mkIf (flake ? rev) flake.rev;
          system.stateVersion = config.stateVersion;
          networking.hostName = name;
          networking.hostId = config.hostid;
          nix.package = pkgs.nixFlakes;
          nix.extraOptions = "experimental-features = nix-command flakes";
          time.timeZone = config.timeZone;
          console.keyMap = config.keyMap;
        })
      ];

      sharedModules = [
        nur.nixosModules.nur
        ({ lib, ... }: with lib; {
          config.nixpkgs.overlays = [(final: prev: {
            unstable = import unstable {
              inherit (final) system;
              config = { inherit allowUnfreePredicate; };
            };
          })];
          config.nixpkgs.config = { inherit allowUnfreePredicate; };
          options.backup.files = mkOption {
            type = with types; listOf str;
            default = [];
            description = ''
              The files inside home to backup.
            '';
          };
          options.backup.directories = mkOption {
            type = with types; listOf (either str (submodule {
              options = {
                directory = mkOption {
                  type = str;
                  default = null;
                  description = "The directory path to be linked.";
                };
                method = mkOption {
                  type = types.enum [ "bindfs" "symlink" ];
                  default = "bindfs";
                  description = ''
                    The linking method that should be used for this
                    directory. bindfs is the default and works for most use
                    cases, however some programs may behave better with
                    symlinks.
                  '';
                };
              };
            }));
            default = [];
            description = ''
              The directories inside home to backup.
            '';
          };
        })
      ];

      specialArgs = {
        inherit (config) users;
        inherit inputs;
        hostname = name;
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

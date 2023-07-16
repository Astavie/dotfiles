{ lib, config, flake, home-manager, nixpkgs, overlays, musnix, ... }:

with lib;
let
  unfree = import ../unfree.nix;
  allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) unfree;
  nospace  = str: filter (c: c == " ") (stringToCharacters str) == [];
  timezone = types.nullOr (types.addCheck types.str nospace)
    // { description = "null or string without spaces"; };
in
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
            packages = mkOption {
              type = types.listOf types.package;
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
            backup.files = mkOption {
              type = with types; listOf str;
              default = [];
              description = ''
                The files inside home to backup.
              '';
            };
            backup.directories = mkOption {
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

            hm = home-manager.lib.homeManagerConfiguration {
              pkgs = nixpkgs.legacyPackages.${config.system};

              extraSpecialArgs = {
                inherit (u.config) dir;
              };

              modules = u.config.modules ++ [{
                config = {
                  home.packages = u.config.packages;
                  home.homeDirectory = u.config.dir.home;
                  home.username = name;
                  home.stateVersion = config.stateVersion;
                  nixpkgs.overlays = overlays;
                  nixpkgs.config = {
                    inherit allowUnfreePredicate;
                    permittedInsecurePackages = unfree;
                  };
                  backup.files = u.config.backup.files;
                  backup.directories = u.config.backup.directories;
                };

                # TODO: remove the use for the following two options
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
              }];
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
      sudo = mkOption {
        type = types.enum [ "doas" "sudo" ];
        default = "doas";
        example = "sudo";
        description = ''
          What package to use for sudo
        '';
      };
      backup.files = mkOption {
        type = with types; listOf str;
        default = [];
        description = ''
          The files inside root to backup.
        '';
      };
      backup.directories = mkOption {
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
          The directories inside root to backup.
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
      superusers = mkOption {
        type = with types; listOf string;
        readOnly = true;
        description = ''
          The list of superusers.
        '';
      };
    };
    config = {
      modules = [
        musnix.nixosModules.musnix
        ({ lib, pkgs, ... }: with lib; {
          config = {
            nixpkgs.overlays = overlays;
            nixpkgs.config = {
              inherit allowUnfreePredicate;
              permittedInsecurePackages = unfree;
            };
            system.configurationRevision = mkIf (flake ? rev) flake.rev;
            system.stateVersion = config.stateVersion;
            networking.hostName = config.hostname;
            networking.hostId = config.hostid;
            nix.package = pkgs.nixFlakes;
            nix.extraOptions = "experimental-features = nix-command flakes";
            time.timeZone = config.timeZone;
            console.keyMap = config.keyMap;

            security.sudo.enable = config.sudo == "sudo";
            security.doas.enable = config.sudo == "doas";

            # NOTE: we could add options for this?
            # console.font = ../res/cozette.psf;
            boot.supportedFilesystems = [ "ntfs" ];
          };
        })
      ];

      nixos = nixosSystem {
        inherit (config) system modules;
      };

      superusers = builtins.attrNames (lib.filterAttrs (_: usercfg: usercfg.superuser) config.users);
    };
  }

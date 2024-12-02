{lib, config, inputs, pkgs, ...}:

let
  unfree = import ../unfree.nix;
  allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) unfree;
  subset = module: lib.mkOption {
    type = with lib.types; attrsOf (submodule module);
  };
  overlay-names = builtins.filter (lib.hasPrefix "overlay-") (lib.mapAttrsToList (name: _: name) inputs);
  overlays = builtins.map (name: inputs.${name}.overlays.default) overlay-names;
in
{
  options.asta = {
    sudo = lib.mkOption {
      type = lib.types.enum [ "doas" "sudo" ];
      default = "doas";
      example = "sudo";
      description = ''
        What package to use for sudo
      '';
    };
    backup.files = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = ''
        The files inside home to backup.
      '';
    };
    backup.directories = lib.mkOption {
      type = lib.types.listOf (lib.types.either lib.types.str (lib.types.submodule {
        options = {
          directory = lib.mkOption {
            type = lib.types.str;
            default = null;
            description = "The directory path to be linked.";
          };
          method = lib.mkOption {
            type = lib.types.enum [ "bindfs" "symlink" ];
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
    modules = lib.mkOption {
      type = lib.types.listOf lib.types.raw;
      default = [];
      description = ''
        Extra modules for all users.
      '';
    };
    users = subset ({ name, ... }@u: {
      options = {
        # Required options
        modules = lib.mkOption {
          type = lib.types.listOf lib.types.raw;
          description = ''
            The modules of the user.
          '';
        };

        # Optional options
        dir.home = lib.mkOption {
          type = lib.types.path;
          apply = toString;
          description = ''
            The home directory of the user.
          '';
        };
        dir.data = lib.mkOption {
          type = lib.types.path;
          apply = toString;
          description = ''
            The data directory of the user.
          '';
        };
        dir.config = lib.mkOption {
          type = lib.types.functionTo lib.types.path;
          apply = (f: (x: toString (f x)));
          description = ''
            A directory to place configuration files of a specific package.
          '';
        };
      };
      config = {
        dir.home = lib.mkDefault "/home/${name}";
        dir.data = lib.mkDefault "/data/${name}";
        dir.config = lib.mkDefault (_: u.config.dir.home);

        modules = [{
          config = {
            home.homeDirectory = u.config.dir.home;
            home.username = name;
            home.stateVersion = "23.05";
          };

          options.asta = {
            backup.files = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [];
              description = ''
                The files inside home to backup.
              '';
            };
            backup.directories = lib.mkOption {
              type = lib.types.listOf (lib.types.either lib.types.str (lib.types.submodule {
                options = {
                  directory = lib.mkOption {
                    type = lib.types.str;
                    default = null;
                    description = "The directory path to be linked.";
                  };
                  method = lib.mkOption {
                    type = lib.types.enum [ "bindfs" "symlink" ];
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
          };
        }];
      };
    });
  };

  imports = [
    inputs.musnix.nixosModules.musnix
    inputs.home-manager.nixosModules.home-manager
    ./modules
  ];

  config = {
    # nixos settings
    nixpkgs.overlays = overlays;
    nixpkgs.config = {
      inherit allowUnfreePredicate;
      permittedInsecurePackages = unfree;
    };
    system.configurationRevision = lib.mkIf (inputs.self ? rev) inputs.self.rev;
    system.stateVersion = "23.05";

    nix.package = pkgs.nixVersions.stable;
    nix.extraOptions = "experimental-features = nix-command flakes";
    nix.settings.trusted-users = [ "@wheel" ];

    security.sudo.enable = config.asta.sudo == "sudo";
    security.doas.enable = config.asta.sudo == "doas";

    # reasonable defaults
    time.timeZone = "Europe/Amsterdam";
    console.keyMap = "us";
    console.font = ../res/cozette.psf;
    boot.supportedFilesystems = [ "ntfs" ];

    programs.fish.enable = true;
    programs.git.enable = true;

    # home manager
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users = lib.mapAttrs (_: usercfg: { imports = config.asta.modules ++ usercfg.modules; }) config.asta.users;
    home-manager.extraSpecialArgs = { inherit inputs; };

    # dconf
    programs.dconf.enable = true;
    asta.modules = [{
      asta.backup.directories = ["gsettings/.config/dconf"];
    }];

    # users
    users.mutableUsers = false;
    users.users = lib.mapAttrs (_: cfg: {
      home = cfg.dir.home;
      shell = pkgs.fish;
      extraGroups = [ "audio" "video" ];
    }) config.asta.users;
  };
}

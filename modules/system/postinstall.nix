{ pkgs, config, lib, ... }:

{
  options.postinstall = lib.mkOption {
    default = [];
    description = ''
      A set of scripts to be executed after the nixos install.
    '';
    type = lib.types.listOf (
      lib.types.submodule {
        options = {
          generator = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = ''
              A shell script to execute.
            '';
          };
        };
      }
    );
  };

  config.environment.systemPackages = [
    (pkgs.writeShellScriptBin "postinstall" (
      builtins.concatStringsSep "\n" (
        builtins.map (secret: secret.generator) config.postinstall
      )
    ))
  ];
}

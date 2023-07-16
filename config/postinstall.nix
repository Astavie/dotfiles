
{ lib, config, ... }:

with lib;
{
  options.postinstall = {
    scripts = mkOption {
      default = [];
      description = ''
        A set of scripts to be executed after the nixos install.
      '';
      type = types.listOf (
        types.submodule {
          options = {
            script = mkOption {
              type = types.str;
              default = "";
              description = ''
                A shell script to execute.
              '';
            };
            user = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = ''
                The user to run the script as.
              '';
            };
            dirs = mkOption {
              type = types.listOf types.str;
              default = [];
              description = ''
                A list of directories to create before running the script.
              '';
            };
          };
        }
      );
    };
  };

  config.modules = [({ pkgs, ... }: {
    config.environment.systemPackages = [
      (pkgs.writeShellScriptBin "postinstall" (
        builtins.concatStringsSep "\n" (
          builtins.map ({ script, user, dirs }:
            let 
              func = if dirs == []
                then script
                else "mkdir -p ${builtins.concatStringsSep " " (builtins.map (dir: "'${dir}'") dirs)}\n${script}";
            in
              if user == null
                then func
                else "${config.sudo} -s -u ${user} <<'EOF'\n${func}\nEOF"
          ) config.postinstall.scripts
        )
      ))
    ];
  })];
}

{ pkgs, config, lib, ... }:

{
  options.postinstall = {
    sudo = lib.mkOption {
      type = lib.types.str;
      default = "sudo";
      description = ''
        The command to use to run a command as a different user.
      '';
    };
    scripts = lib.mkOption {
      default = [];
      description = ''
        A set of scripts to be executed after the nixos install.
      '';
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            script = lib.mkOption {
              type = lib.types.str;
              default = "";
              description = ''
                A shell script to execute.
              '';
            };
            user = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = ''
                The user to run the script as.
              '';
            };
            dirs = lib.mkOption {
              type = lib.types.listOf lib.types.str;
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
              else "${config.postinstall.sudo} -s -u ${user} <<'EOF'\n${func}\nEOF"
        ) config.postinstall.scripts
      )
    ))
  ];
}

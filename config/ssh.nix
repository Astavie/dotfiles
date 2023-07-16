{ lib, config, pkgs, ... }:

with lib;
let
  subset = module: mkOption {
    type = with types; attrsOf (submodule module);
  };
  ssh-users = lib.filterAttrs (_: usercfg: usercfg.ssh.enable) config.users;
in
{
  options.users = subset (u: {
    options = {
      ssh.enable = mkEnableOption "ssh";
    };
    config = {
      backup.directories = mkIf u.config.ssh.enable [
        "ssh/.ssh"
      ];
    };
  });
  config = {
    postinstall.scripts = lib.mapAttrsToList (username: usercfg: {
      script = "${pkgs.openssh}/bin/ssh-keygen -t rsa -b 4096 -f ${usercfg.dir.config "ssh"}/.ssh/id_rsa -N ''";
      user = username;
      dirs = [ "${usercfg.dir.config "ssh"}/.ssh" ];
    }) ssh-users;
  };
}

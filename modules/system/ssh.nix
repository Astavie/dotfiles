{ lib, users, pkgs, ... }:

let
  # list of users with ssh-keygen flag
  ssh-users = lib.filterAttrs (_: usercfg: usercfg.specialArgs.ssh-keygen or false) users;
in
{
  postinstall.scripts = lib.mapAttrsToList (username: usercfg: {
    script = "${pkgs.openssh}/bin/ssh-keygen -t rsa -b 4096 -f ${usercfg.dir.config "ssh"}/.ssh/id_rsa -N ''";
    user = username;
    dirs = [ "${usercfg.dir.config "ssh"}/.ssh" ];
  }) ssh-users;
}

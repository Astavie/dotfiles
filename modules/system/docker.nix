{ users, lib, ... }:

let
  superusers = lib.filterAttrs (_: usercfg: usercfg.superuser) users;
in
{
  virtualisation.docker.enable = true;
  users.extraGroups.docker.members = builtins.attrNames superusers;
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };
}

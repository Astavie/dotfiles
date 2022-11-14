{ users, lib, ... }:

let
  superusers = lib.filterAttrs (_: usercfg: usercfg.superuser) users;
in
{
  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = builtins.attrNames superusers;
}

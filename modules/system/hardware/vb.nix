{ users, lib, ... }:

let
  superusers = lib.filterAttrs (_: usercfg: usercfg.superuser) users;
in
{
  virtualisation.virtualbox.guest.enable = true;
  users.extraGroups.vboxsf.members = builtins.attrNames superusers;
}

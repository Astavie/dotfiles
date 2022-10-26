{ users, lib, ... }:

let
  superusers = lib.filterAttrs (_: usercfg: usercfg.superuser) users;
in
{
  virtualisation.virtualbox.guest.enable = true;

  users.users = lib.mapAttrs (_: _: {
    extraGroups = [ "vboxsf" ];
  }) superusers;
}

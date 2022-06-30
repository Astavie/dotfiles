{ users, lib, ... }:

let
  superusers = lib.filterAttrs
    (_: usercfg: usercfg ? superuser && usercfg.superuser)
    users;
in
{
  virtualisation.virtualbox.guest.enable = true;

  users.users = lib.mapAttrs' (username: usercfg:
    lib.nameValuePair username {
      extraGroups = [ "vboxsf" ];
    }
  ) superusers;
}

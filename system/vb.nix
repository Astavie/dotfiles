{ users, lib, ... }:

let
  superusers = builtins.filter (usercfg: usercfg.superuser) users;
in
{
  virtualisation.virtualbox.guest.enable = true;
  
  users.users = builtins.listToAttrs (builtins.map (usercfg:
    lib.nameValuePair usercfg.username {
      extraGroups = [ "vboxsf" ];
    }
  ) superusers);
}

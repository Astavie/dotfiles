{ config, ... }:

{
  virtualisation.virtualbox.guest.enable = true;
  users.users."astavie".extraGroups = [ "vboxsf" ];
}

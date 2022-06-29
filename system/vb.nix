{ username, ... }:

{
  virtualisation.virtualbox.guest.enable = true;
  users.users.${username}.extraGroups = [ "vboxsf" ];
}

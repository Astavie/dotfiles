{ lib, config, ... }:

lib.module config "vbhost" {
  asta.backup.directories = [
    "virtualbox/.config/VirtualBox"
  ];
} (users: {
  virtualisation.virtualbox.host.enable = true;
  boot.kernelParams = [ "kvm.enable_virt_at_load=0" ];
  users.extraGroups.vboxusers.members = builtins.attrNames users;
})

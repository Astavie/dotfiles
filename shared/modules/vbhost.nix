{ lib, config, ... }:

let
  vbhost-users = lib.enabled "vbhost" config.asta.users;
in
{
  options.asta.users = lib.subset (u: {
    options = {
      vbhost.enable = lib.mkEnableOption "vbhost";
    };
    config = lib.mkIf u.config.vbhost.enable {
      modules = [{
        asta.backup.directories = [
          "virtualbox/.config/VirtualBox"
        ];
      }];
    };
  });

  config = lib.mkIf (vbhost-users != {}) {
    virtualisation.virtualbox.host.enable = true;
    boot.kernelParams = [ "kvm.enable_virt_at_load=0" ];
    users.extraGroups.vboxusers.members = builtins.attrNames vbhost-users;
  };
}

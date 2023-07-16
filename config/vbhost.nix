{ lib, config, ... }:

with lib;
{
  options.vbhost.enable = mkEnableOption "vbhost";

  config.modules = mkIf config.vbhost.enable [{
    virtualisation.virtualbox.host.enable = true;
    users.extraGroups.vboxusers.members = config.superusers;
  }];
}

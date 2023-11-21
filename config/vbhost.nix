{ lib, config, ... }:

with lib;
let
  subset = module: mkOption {
    type = with types; attrsOf (submodule module);
  };
in
{
  options.vbhost.enable = mkEnableOption "vbhost";
  options.users = subset {
    backup.directories = mkIf config.vbhost.enable [
      "virtualbox/.config/VirtualBox"
    ];
  };

  config.modules = mkIf config.vbhost.enable [{
    virtualisation.virtualbox.host.enable = true;
    users.extraGroups.vboxusers.members = config.superusers;
  }];
}

{ lib, config, ... }:

let
  subset = module: lib.mkOption {
    type = with lib.types; attrsOf (submodule module);
  };
  vbhost-users = lib.filterAttrs (_: cfg: cfg.vbhost.enable) config.asta.users;
in
{
  options.asta.users = subset (u: {
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
    users.extraGroups.vboxusers.members = builtins.attrNames vbhost-users;
  };
}

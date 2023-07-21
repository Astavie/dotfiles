{ lib, config, pkgs, ... }:

with lib;
let
  subset = module: mkOption {
    type = with types; attrsOf (submodule module);
  };
  wireshark-users = filterAttrs (_: usercfg: usercfg.wireshark.enable) config.users;
in
{
  options.users = subset (u: {
    options = {
      wireshark.enable = mkEnableOption "wireshark";
    };
    config = {
      packages = mkIf u.config.wireshark.enable [
        pkgs.wireshark
        pkgs.wirelesstools
        pkgs.iw
      ];
    };
  });

  config.modules = mkIf (builtins.attrNames wireshark-users != []) [{

    users.groups.wireshark = {};

    users.users = builtins.mapAttrs (name: _: {
      extraGroups = [ "wireshark" ];
    }) wireshark-users;

    security.wrappers.dumpcap = {
      source = "${pkgs.wireshark}/bin/dumpcap";
      capabilities = "cap_net_raw,cap_net_admin+eip";
      owner = "root";
      group = "wireshark";
      permissions = "u+rx,g+x";
    };

  }];
}


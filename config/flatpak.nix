{ lib, config, pkgs, ... }:

with lib;
let
  subset = module: mkOption {
    type = with types; attrsOf (submodule module);
  };
  flatpak-users = filterAttrs (_: usercfg: usercfg.flatpak.enable) config.users;
in
{
  options.users = subset (u: {
    options = {
      flatpak.enable = mkEnableOption "flatpak";
    };
    config = {
      packages = mkIf u.config.flatpak.enable [
        pkgs.flatpak
      ];
      backup.directories = mkIf u.config.flatpak.enable [
        "flatpak/.local/share/flatpak"
      ];
    };
  });

  config.modules = mkIf (flatpak-users != []) [({ pkgs, ... }: {
    # environment.systemPackages = [ pkgs.flatpak ];
    security.polkit.enable = true;
    services.dbus.packages = [ pkgs.flatpak ];
    systemd.packages = [ pkgs.flatpak ];

    environment.profiles = [
      "$HOME/.local/share/flatpak/exports"
      # "/var/lib/flatpak/exports"
    ];

    users.users.flatpak = {
      description = "Flatpak system helper";
      group = "flatpak";
      isSystemUser = true;
    };

    users.groups.flatpak = { };
  })];
}

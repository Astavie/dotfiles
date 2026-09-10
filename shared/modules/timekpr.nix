{ lib, config, pkgs, ... }:

{
  options.asta = {
    timekpr.enable = lib.mkEnableOption "timekpr";
  };

  config = lib.mkIf config.asta.timekpr.enable {

    services.timekpr.enable = true;
    services.timekpr.package = pkgs.timekpr.overrideAttrs (old: {
      buildInputs = (old.buildInputs or []) ++ [pkgs.libayatana-appindicator];
    });

    asta.backup.directories = [
      # "/etc/timekpr"
      "/var/lib/timekpr"
    ];

    asta.modules = [{
      asta.backup.directories = [
        "timekpr/.config/timekpr"
      ];
      wayland.windowManager.hyprland.settings.exec-once = [
        "timekprc"
      ];
    }];

  };
}

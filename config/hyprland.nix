{ pkgs, config, lib, ... }:

with lib;
let
  subset = module: mkOption {
    type = with types; attrsOf (submodule module);
  };
  hyprland = pkgs.hyprland.override {
    enableXWayland = true;
  };
  hyprland-users = filterAttrs (_: usercfg: usercfg.hyprland.enable) config.users;
in
{
  options.users = subset (u: {
    options = {
      hyprland.enable = mkEnableOption "hyprland";
    };
    config = {
      packages = mkIf u.config.hyprland.enable [
        hyprland
      ];
      modules = mkIf u.config.hyprland.enable [{
        home.sessionVariables = {
          LIBVA_DRIVER_NAME = "nvidia";
          XDG_SESSION_TYPE = "wayland";
          GBM_BACKEND = "nvidia-drm";
          __GLX_VENDOR_LIBRARY_NAME = "nvidia";
          WLR_NO_HARDWARE_CURSORS = 1;
        };
        home.file.".config/hypr/hyprland.conf".onChange = ''
          (
            shopt -s nullglob
            for instance in /tmp/hypr/*; do
              HYPRLAND_INSTANCE_SIGNATURE=''${instance##*/} ${hyprland}/bin/hyprctl reload config-only \
                || true
            done
          )
        '';
      }];
    };
  });

  config.modules = mkIf (builtins.attrNames hyprland-users != []) [{
    programs.dconf.enable = true;
    programs.xwayland.enable = true;
    security.polkit.enable = true;
    hardware.opengl.enable = true;
    fonts.enableDefaultPackages = true;

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
      config.common.default = "*";
    };
  }];
}

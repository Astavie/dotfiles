{ pkgs, ... }:

{
  home.packages = [pkgs.libtas];
  asta.backup.directories = [
    "libtas/.local/share/libTAS"
    "libtas/.config/libTAS"
    "libtas/.config/unity3d/Team Cherry/Hollow Knight"
  ];

  # add TAS workspace where everything is a floating window
  wayland.windowManager.hyprland.settings = {
    bind = [
      "$mod, T, workspace, name:tas"
    ];
    windowrule = [
      "float 1, match:workspace name:tas"
    ];
  };
}

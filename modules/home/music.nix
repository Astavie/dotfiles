{ pkgs, ... }:

{
  home.packages = with pkgs; [
    ardour
    sfizz
    yabridge
    yabridgectl
    soundfont-fluid
    wineWowPackages.staging
  ];

  home.file.".vst/sfizz.vst3".source = "${pkgs.sfizz}/lib/vst3/sfizz.vst3";

  backup.directories = [
    "vst_windows/.wine/drive_c"
    "vst_windows/.vst/yabridge"
    "ardour/.config/ardour7"
  ];
}

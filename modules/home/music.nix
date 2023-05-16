{ pkgs, ... }:

{
  home.packages = with pkgs; [
    ardour
    yabridge
    yabridgectl
    soundfont-fluid
    wineWowPackages.staging
    qsampler
    linuxsampler
  ];

  home.file.".vst/sfizz.vst3".source = "${pkgs.sfizz}/lib/vst3/sfizz.vst3";
  home.file.".vst/helm".source = "${pkgs.helm}/lib/lxvst";

  backup.directories = [
    "vst_windows/.wine/drive_c"
    "vst_windows/.vst/yabridge"
    "ardour/.config/ardour7"
  ];
}

{ pkgs, ... }:

{
  home.packages = with pkgs; [
    ardour
    yabridge
    yabridgectl
    soundfont-fluid
    wineWowPackages.staging

    x42-plugins
    linuxsampler
    qsampler
  ];

  home.file.".vst3/sfizz.vst3".source = "${pkgs.sfizz}/lib/vst3/sfizz.vst3";
  home.file.".vst/helm".source = "${pkgs.helm}/lib/lxvst";
  home.file.".vst/lsp-plugins".source = "${pkgs.lsp-plugins}/lib/vst/lsp-plugins";

  backup.directories = [
    "yabridge/.wine"
    "yabridge/.vst/yabridge"
    "yabridge/.vst3/yabridge"
    "yabridge/.config/yabridgectl"
    "ardour/.config/ardour7"
    "ardour/.cache/ardour7"
  ];
}

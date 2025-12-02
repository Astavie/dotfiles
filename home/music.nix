{ pkgs, ... }:

{
  home.packages = with pkgs; [
    ardour
    # zrythm

    soundfont-fluid
    execline
    x42-plugins
    helm

    musescore
    muse-sounds-manager
  ];

  home.file.".vst3/sfizz.vst3".source = "${pkgs.sfizz}/lib/vst3/sfizz.vst3";
  home.file.".vst3/Vital.vst3".source = "${pkgs.vital}/lib/vst3/Vital.vst3";

  home.file.".vst/Vital.so".source = "${pkgs.vital}/lib/vst/Vital.so";
  home.file.".vst/lsp-plugins".source = "${pkgs.lsp-plugins}/lib/vst/lsp-plugins";

  asta.backup.directories = [
    "ardour/.config/ardour7"
    "ardour/.cache/ardour7"
    "ardour/.config/ardour8"
    "ardour/.cache/ardour8"
    "vital/.local/share/vital"
    "musescore/.local/share/MuseSampler"
    "musescore/.local/share/MuseScore"
    "musescore/.muse-sounds-manager"
    "musescore/.config/MuseScore"
  ];
}

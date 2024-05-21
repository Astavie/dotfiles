{ pkgs, ... }:

{
  home.packages = with pkgs; [
    ardour
    zrythm
    soundfont-fluid
    wine
    execline
    yabridge
    yabridgectl

    x42-plugins
    # linuxsampler
    # qsampler
  ];

  home.file.".vst3/sfizz.vst3".source = "${pkgs.sfizz}/lib/vst3/sfizz.vst3";
  home.file.".vst3/Vital.vst3".source = "${pkgs.vital}/lib/vst3/Vital.vst3";

  home.file.".vst/Vital.so".source = "${pkgs.vital}/lib/vst/Vital.so";
  home.file.".vst/lsp-plugins".source = "${pkgs.lsp-plugins}/lib/vst/lsp-plugins";
  # home.file.".vst/helm".source = "${pkgs.helm.overrideAttrs {
  #   src = pkgs.fetchFromGitHub {
  #     owner = "Jikstra";
  #     repo = "helm";
  #     rev = "d6a02fe309f47cf125cfb811466454a617b1745e";
  #     hash = "sha256-pAVDvBAAG2X2tGDojG4DfFaoviDsuF04hMaxYyHsdCg=";
  #   };
  #   patches = [];
  # }}/lib/lxvst";

  backup.directories = [
    "yabridge/.wine"
    "yabridge/.vst/yabridge"
    "yabridge/.vst3/yabridge"
    "yabridge/.config/yabridgectl"
    "ardour/.config/ardour7"
    "ardour/.cache/ardour7"
    "ardour/.config/ardour8"
    "ardour/.cache/ardour8"
    "vital/.local/share/vital"
  ];
}

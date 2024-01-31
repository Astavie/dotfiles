{ pkgs, ... }:

let
  # wine staging is currently at 9.0-rc1, which broke the system for some reason
  # so for now we are back using wine stable
  wine = pkgs.wineWowPackages.stableFull;
in
{
  home.packages = with pkgs; [
    ardour
    soundfont-fluid
    wine
    execline
    (yabridge.override { inherit wine; })
    (yabridgectl.override { inherit wine; })

    x42-plugins
    # linuxsampler
    # qsampler
  ];

  home.file.".vst3/sfizz.vst3".source = "${pkgs.sfizz}/lib/vst3/sfizz.vst3";
  home.file.".vst/helm".source = "${pkgs.helm.overrideAttrs {
    src = pkgs.fetchFromGitHub {
      owner = "Jikstra";
      repo = "helm";
      rev = "d6a02fe309f47cf125cfb811466454a617b1745e";
      hash = "sha256-pAVDvBAAG2X2tGDojG4DfFaoviDsuF04hMaxYyHsdCg=";
    };
    patches = [];
  }}/lib/lxvst";
  home.file.".vst/lsp-plugins".source = "${pkgs.lsp-plugins}/lib/vst/lsp-plugins";

  backup.directories = [
    "yabridge/.wine"
    "yabridge/.vst/yabridge"
    "yabridge/.vst3/yabridge"
    "yabridge/.config/yabridgectl"
    "ardour/.config/ardour7"
    "ardour/.cache/ardour7"
    "ardour/.config/ardour8"
    "ardour/.cache/ardour8"
  ];
}

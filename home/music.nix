{ pkgs, ... }:

let
  musescore = let
    pname = "musescore-appimage";
    version = "4.4.4";
    src = pkgs.fetchurl {
      url = "https://cdn.jsdelivr.net/musescore/v${version}/MuseScore-Studio-${version}.243461245-x86_64.AppImage";
      hash = "sha256-g5mb9mPqh5lDV2wIBugzFMKtjJzGuXm5mIZVvsyRBh4=";
    };
    appimageContents = pkgs.appimageTools.extractType2 { inherit pname version src; };
  in pkgs.appimageTools.wrapType2 {
    inherit pname version src;

    extraInstallCommands = ''
      install -Dm444 ${appimageContents}/share/applications/org.musescore.MuseScore4portable.desktop -t $out/share/applications
      substituteInPlace $out/share/applications/org.musescore.MuseScore4portable.desktop \
        --replace-fail 'Exec=mscore4portable %U' 'Exec=${pname}'
      cp -r ${appimageContents}/share/icons $out/share
    '';
  };
in
{
  home.packages = with pkgs; [
    ardour
    zrythm

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

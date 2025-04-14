# hahahaha home/stuck get it ?? HOMESTUCK
{ pkgs, ... }:

let
  uhc = let
    pname = "unofficial-homestuck-collection";
    version = "2.5.7";
    src = pkgs.fetchurl {
      url = "https://github.com/homestuck/unofficial-homestuck-collection/releases/download/${version}/The-Unofficial-Homestuck-Collection-${version}.AppImage";
      hash = "sha256-Nd+Uf3HY8MNx/8IZW5lLqsead6LMptjyVT1tTfl8K1A=";
    };
    appimageContents = pkgs.appimageTools.extractType2 { inherit pname version src; };
  in pkgs.appimageTools.wrapType2 {
    inherit pname version src;

    extraInstallCommands = ''
      install -Dm444 ${appimageContents}/unofficial-homestuck-collection.desktop -t $out/share/applications
      substituteInPlace $out/share/applications/unofficial-homestuck-collection.desktop \
        --replace-fail 'Exec=AppRun --no-sandbox %U' 'Exec=${pname} --no-sandbox'
      cp -r ${appimageContents}/usr/share/icons $out/share
    '';
  };
in
{
  home.packages = [
    uhc
  ];
  asta.backup.directories = [
    "homestuck/.config/unofficial-homestuck-collection"
    "homestuck/.config/unofficial-homestuck-collection-assets"
  ];
}

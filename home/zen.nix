{ pkgs, ... }:

let
  zen = pkgs.appimageTools.wrapType2 {
    pname = "zen";
    version = "1.0.1-t.10";
    src = pkgs.fetchurl {
      url = "https://github.com/zen-browser/desktop/releases/download/twilight/zen-specific.AppImage";
      hash = "sha256-2/EsoQfCx54YVLlrj+Hc1IzSwBvdfbX0upsye0AcU0Q=";
    };
  };
in
{
  home.packages = [zen];
  asta.backup.directories = [
    "zen/.zen"
  ];
}

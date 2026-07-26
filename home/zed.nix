{ pkgs, ... }:

{
  home.packages = [ pkgs.unstable.zed-editor ];
  asta.backup.directories = [
    "zed/.config/zed"
    "zed/.local/share/zed"
  ];
}

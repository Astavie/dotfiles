{ pkgs, ... }:

{
  home.packages = [pkgs.libtas];
  asta.backup.directories = [
    "libtas/.local/share/libTAS"
    "libtas/.config/libTAS"
    "libtas/.config/unity3d/Team Cherry/Hollow Knight"
  ];
}

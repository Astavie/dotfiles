{ pkgs, ... }:

{
  home.packages = with pkgs; [
    xdg-utils
    xwaylandvideobridge
    vesktop
  ];

  asta.backup.directories = [
    "discord/.config/discord"
  ];
}

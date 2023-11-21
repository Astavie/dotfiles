{ pkgs, ... }:

{
  home.packages = with pkgs; [
    xdg-utils
    (discocss.override { discordAlias = true; })
    xwaylandvideobridge
  ];

  backup.directories = [
    "discord/.config/discord"
  ];
}

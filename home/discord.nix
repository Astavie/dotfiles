{ pkgs, ... }:

{
  home.packages = with pkgs; [
    xdg-utils
    discord-screenaudio
    (discocss.override { discordAlias = true; })
    xwaylandvideobridge
  ];

  backup.directories = [
    "discord/.config/discord"
  ];
}

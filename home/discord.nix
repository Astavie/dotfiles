{ pkgs, ... }:

{
  home.packages = with pkgs; [
    (discocss.override { discordAlias = true; })
  ];

  backup.directories = [
    "discord/.config/discord"
    "discord-screenaudio/.var/app/de.shorsh.discord-screenaudio/data/discord-screenaudio"
  ];
}

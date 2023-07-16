{ pkgs, ... }:

{
  home.packages = with pkgs; [
    (discocss.override { discordAlias = true; })
  ];

  home.file.".config/discocss/custom.css".source = ../res/discord.css;

  backup.directories = [
    "discord/.config/discord"
    "discord-screenaudio/.var/app/de.shorsh.discord-screenaudio/data/discord-screenaudio"
  ];
}

{ pkgs, config, ... }:

{
  home.packages = with pkgs; [
    (discocss.override { discordAlias = true; })
  ];

  home.file.".config/discocss/custom.css".source = ../../config/discord.css;

  backup.directories = [
    "discord/.config/discord"
    "discord-screenaudio/.var/app/de.shorsh.discord-screenaudio/data/discord-screenaudio"
    "flatpak/.local/share/flatpak"
  ];

  xdg.systemDirs.data = [ "${config.home.homeDirectory}/.local/share/flatpak/exports/share" ];
}

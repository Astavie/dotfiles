{ pkgs, ... }:

{
  home.packages = with pkgs; [
    xdg-utils
    vesktop
  ];

  asta.backup.directories = [
    "discord/.config/discord"
    "discord/.config/vesktop"
  ];
}

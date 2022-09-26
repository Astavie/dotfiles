{ pkgs, ... }:

{
  home.packages = with pkgs; [
    steam
  ];

  backup.directories = [
    "steam/.steam"
    "steam/.local/share/Steam"
  ];
}

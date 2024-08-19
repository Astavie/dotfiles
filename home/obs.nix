{ pkgs, ... }:

{
  home.packages = [ pkgs.obs-studio ];

  asta.backup.directories = [ "obs/.config/obs-studio" ];
}

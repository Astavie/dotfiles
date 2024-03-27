{ pkgs, ... }:

{
  home.packages = [ pkgs.obs-studio ];
  backup.directories = [ "obs/.config/obs-studio" ];
}

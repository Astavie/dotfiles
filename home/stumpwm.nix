{ pkgs, ... }:

{
  home.packages = [ pkgs.stumpwm ];
  home.file.".stumpwmrc".source = ../config/.stumpwmrc;
  home.file.".config/sx/sxrc" = {
    executable = true;
    text = "${pkgs.stumpwm}/bin/stumpwm";
  };
}

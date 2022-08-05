{ pkgs, ... }:

{
  home.packages = with pkgs; [
    stumpwm
    xorg.xmodmap
  ];

  home.file.".stumpwmrc".source = ../../config/.stumpwmrc;

  home.file.".config/sx/sxrc" = {
    executable = true;
    text = ''
      ${pkgs.xorg.xmodmap}/bin/xmodmap -e "clear mod4"
      ${pkgs.stumpwm}/bin/stumpwm
    '';
  };
}

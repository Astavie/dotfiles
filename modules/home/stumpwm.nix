{ pkgs, ... }:

{
  home.packages = with pkgs; [
    stumpwm
    xorg.xmodmap
  ];

  home.file.".stumpwmrc".source = ../../config/.stumpwmrc;
  home.file.".stumpwm.d/modules".source = pkgs.fetchFromGitHub {
    owner = "stumpwm";
    repo = "stumpwm-contrib";
    rev = "6d4584f01dec0143a169186df1608860d1aa1ef0";
    sha256 = "sha256-ts+MPFtLCjj6T2MuOxWSKfNCv9gvS348SV6IztUfx8M=";
  };

  home.file.".config/sx/sxrc" = {
    executable = true;
    text = ''
      ${pkgs.xorg.xmodmap}/bin/xmodmap -e "clear mod4"
      ${pkgs.stumpwm}/bin/stumpwm
    '';
  };
}

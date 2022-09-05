{ pkgs, ... }:

{
  home.packages = with pkgs; [
    stumpwm
    xorg.xmodmap
    feh
  ];

  services.picom = {
    enable = true;
    extraOptions = ''
      corner-radius = 5;
      round-borders = 5;
      rounded-corners-exclude = [
        "class_g ?= 'Notify-osd'",
        "class_g = 'dmenu'",
        "class_g = 'Polybar'",
        "class_g = 'Tint2'",
        "!window_type = 'normal'"
      ];
      shadow = true;
      shadow-radius = 10;
      shadow-opacity = 0.5;
      shadow-offset-x = -18;
      shadow-offset-y = 0;
      shadow-red = 0.0;
      shadow-green = 0.0;
      shadow-blue = 0.0;
      xinerama-shadow-crop = true;
      shadow-exclude = [
        "class_g ?= 'Notify-osd'",
        "class_g = 'spectrwm'",
        "class_g = 'dmenu'",
        "class_g = 'Easystroke'",
        "class_g = 'Rofi'",
        "class_g = 'GLava'",
        "class_g = '_HERBST_FRAME'",
      ];
    '';
  };

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
      feh --bg-fill ${../../config/wallpaperlight.png} &
      picom &
      ${pkgs.stumpwm}/bin/stumpwm
    '';
  };
}

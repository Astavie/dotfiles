{ pkgs, ... }:

let
  autostart = pkgs.writeShellScript "autostart" (builtins.readFile ../../config/herbstluftwm.sh);
in
{
  home.packages = with pkgs; [
    herbstluftwm    # window manager
    feh             # wallpaper
    rofi            # app launcher
    kitty           # terminal
    mc              # file explorer
    scrot xclip     # screenshots
    dunst libnotify # notifications

    # fonts
    (nerdfonts.override { fonts = [ "CascadiaCode" ]; })

    # theming
    gtk-engine-murrine
    gnome.gnome-themes-extra
  ];

  fonts.fontconfig.enable = true;
  
  # gtk theme
  home.file.".themes".source = ../../config/gtk;
  
  # dunst theme
  home.file.".config/dunst/dunstrc".source = ../../config/dunstrc;

  # midnight commander
  home.file.".local/share/mc/skins/theme.ini".source = ../../config/mc.ini;
  home.file.".config/mc/ini".text = ''
    [Midnight-Commander]
    skin=theme
    use_internal_edit=false
  '';

  home.file.".config/kitty/kitty.conf".source = ../../config/kitty.conf;

  services.picom = {
    enable = true;
    extraOptions = ''
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
        "class_g = 'GLava'",
        "class_g = '_HERBST_FRAME'",
      ];
    '';
  };

  home.file.".config/rofi/config.rasi".source = ../../config/rofi/config.rasi;
  home.file.".local/share/rofi/themes/theme.rasi".source = ../../config/rofi/theme.rasi;
  
  home.file.".icons/default".source = ../../config/cursor;

  home.file.".config/sx/sxrc" = {
    executable = true;
    text = ''
      ${pkgs.feh}/bin/feh --bg-fill ${../../config/wallpaper.png} &
      ${pkgs.picom}/bin/picom &
      ${pkgs.dunst}/bin/dunst &
      ${pkgs.herbstluftwm}/bin/herbstluftwm -c ${autostart}
    '';
  };
}

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
  };

  home.file.".config/rofi/config.rasi".source = ../../config/rofi/config.rasi;
  home.file.".local/share/rofi/themes/theme.rasi".source = ../../config/rofi/theme.rasi;
  
  home.file.".icons/default".source = ../../config/cursor;

  home.file.".config/sx/sxrc" = {
    executable = true;
    text = ''
      ${pkgs.feh}/bin/feh --bg-fill ${../../config/the_valley.webp} &
      ${pkgs.picom}/bin/picom &
      ${pkgs.dunst}/bin/dunst &
      ${pkgs.herbstluftwm}/bin/herbstluftwm -c ${autostart}
    '';
  };
}

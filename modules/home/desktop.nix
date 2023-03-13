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
    # mc            # file explorer (already in shell.nix)
    scrot xclip     # screenshots
    dunst libnotify # notifications

    # fonts
    (nerdfonts.override { fonts = [ "CascadiaCode" ]; })

    # theming
    gtk-engine-murrine
    gnome.gnome-themes-extra
  ];

  fonts.fontconfig.enable = true;
  services.picom.enable = true;

  # theme
  home.file.".themes".source = ../../config/gtk;
  home.file.".config/dunst/dunstrc".source = ../../config/dunstrc;
  home.file.".config/kitty/kitty.conf".source = ../../config/kitty.conf;
  home.file.".config/rofi/config.rasi".source = ../../config/rofi/config.rasi;
  home.file.".local/share/rofi/themes/theme.rasi".source = ../../config/rofi/theme.rasi;
  home.file.".icons/default".source = ../../config/cursor;

  # startup
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

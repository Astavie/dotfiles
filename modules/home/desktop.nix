{ pkgs, ... }:

let
  autostart = pkgs.writeShellScript "autostart" (builtins.readFile ../../config/herbstluftwm.sh);
in
{
  home.packages = with pkgs; [
    herbstluftwm    # window manager
    feh             # wallpaper
    rofi            # app launcher
    # mc            # file explorer (already in shell.nix)
    scrot xclip     # screenshots
    dunst libnotify # notifications

    # fonts
    (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
    monocraft

    # theming
    gtk-engine-murrine
    gnome.gnome-themes-extra
  ];

  # home.file.".local/share/fonts/misc/cozette.bdf".source = ../../config/cozette_scaled.bdf;
  home.file.".local/share/fonts/misc/cozette.bdf".source = ../../config/cozette.bdf;

  # terminal emulator
  programs.alacritty = {
    enable = true;
    settings = {
      window.opacity = 0.8;

      font.normal.family = "cozette";

      font.offset.x = 1;
      font.offset.y = 0;

      cursor.style.shape = "Beam";

      colors = {
        primary.foreground = "#cdd6f4";
        primary.background = "#1e1e2e";

        normal.black   = "#1e1e2e";
        normal.red     = "#eba0ac";
        normal.green   = "#a6e3a1";
        normal.yellow  = "#f9e2af";
        normal.blue    = "#89b4fa";
        normal.magenta = "#f5c2e7";
        normal.cyan    = "#94e2d5";
        normal.white   = "#bac2de";

        bright.black   = "#585b70";
        bright.red     = "#eba0ac";
        bright.green   = "#a6e3a1";
        bright.yellow  = "#f9e2af";
        bright.blue    = "#89b4fa";
        bright.magenta = "#f5c2e7";
        bright.cyan    = "#94e2d5";
        bright.white   = "#a6adc8";

        transparent_background_colors = true;
      };
    };
  };

  fonts.fontconfig.enable = true;
  services.picom.enable = true;

  # theme
  home.file.".themes".source = ../../config/gtk;
  home.file.".config/dunst/dunstrc".source = ../../config/dunstrc;
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

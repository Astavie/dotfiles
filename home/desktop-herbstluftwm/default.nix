 { pkgs, ... }:

let
  autostart = pkgs.writeShellScript "autostart" (builtins.readFile ./autostart.sh);
in
{
  home.packages = with pkgs; [
    herbstluftwm    # window manager
    feh             # wallpaper
    rofi            # app launcher
    scrot xclip     # screenshots
    dunst libnotify # notifications
  ];

  programs.alacritty.enable = true;
  services.picom.enable = true;

  home.file.".config/sx/sxrc" = {
    executable = true;
    text = ''
      ${pkgs.feh}/bin/feh --bg-fill ${./pluto.jpg} &
      ${pkgs.picom}/bin/picom &
      ${pkgs.dunst}/bin/dunst &
      ${pkgs.herbstluftwm}/bin/herbstluftwm -c ${autostart}
    '';
  };
}

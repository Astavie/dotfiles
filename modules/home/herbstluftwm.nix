{ pkgs, ... }:

let
  autostart = pkgs.writeShellScript "herbstluftwm-autostart" ''
      hc() {
        herbstclient "$@"
      }

      hc emit_hook reload
      hc keyunbind --all

      Mod=Mod4

      hc keybind $Mod-q close
      hc keybind $Mod-Shift-q quit
      hc keybind $Mod-Shift-r reload
      hc keybind $Mod-Return spawn "kitty" /data/$USER/

      hc keybind $Mod-h focus left
      hc keybind $Mod-j focus down
      hc keybind $Mod-k focus up
      hc keybind $Mod-l focus right

      hc keybind $Mod-Shift-h shift left
      hc keybind $Mod-Shift-j shift down
      hc keybind $Mod-Shift-k shift up
      hc keybind $Mod-Shift-l shift right

      hc keybind $Mod-s       split auto 0.5
      hc keybind $Mod-Shift-s split auto 0.67
      hc keybind $Mod-e       split explode

      resizestep=0.02
      hc keybind $Mod-Control-h resize left  +$resizestep
      hc keybind $Mod-Control-j resize down  +$resizestep
      hc keybind $Mod-Control-k resize up    +$resizestep
      hc keybind $Mod-Control-l resize right +$resizestep

      hc keybind $Mod-r remove
      hc keybind $Mod-f floating toggle
      hc keybind $Mod-p pseudotile toggle
      hc keybind $Mod-space cycle_layout 1

      hc keybind $Mod-BackSpace cycle_monitor
      hc keybind $Mod-period    cycle +1
      hc keybind $Mod-comma     cycle -1
      hc keybind $Mod-u         jumpto urgent

      hc mouseunbind --all
      hc mousebind $Mod-Button1 move
      hc mousebind $Mod-Button2 zoom
      hc mousebind $Mod-Button3 resize

      hc set default_frame_layout max
      hc set_layout max

      hc unrule -F
      hc rule focus=on
      hc rule floatplacement=smart
      hc rule windowtype~'_NET_WM_WINDOW_TYPE_(DIALOG|UTILITY|SPLASH)' floating=on
      hc rule windowtype='_NET_WM_WINDOW_TYPE_DIALOG' focus=on
      hc rule windowtype~'_NET_WM_WINDOW_TYPE_(NOTIFICATION|DOCK|DESKTOP)' manage=off
      hc rule fixedsize floating=on

      hc set tree_style '╾│ ├└╼─┐'
      hc set window_gap 0
      hc set frame_padding 0
      hc set frame_gap 12
      hc set smart_window_surroundings 0
      hc set smart_frame_surroundings 1
      hc set mouse_recenter_gap 0

      hc attr theme.tiling.reset 1
      hc attr theme.floating.reset 1
      hc attr theme.border_width       2
      hc attr theme.outer_width        1
      hc attr theme.inner_width        1
      hc attr theme.padding_left       5
      hc attr theme.outer_color '#11111b'
      hc attr theme.inner_color '#181825'
      hc attr theme.active.color '#f5e0dc'
      hc attr theme.normal.color '#181825'

      hc attr theme.title_when multiple_tabs
      hc attr theme.title_height 11
      hc attr theme.active.title_color '#1e1e2e'
      hc attr theme.normal.title_color '#cdd6f4'
      hc attr theme.title_align center
      hc attr theme.title_font 'CaskaydiaCove Nerd Font:pixelsize=12'
      hc attr theme.title_depth 1
      hc attr theme.tab_color '#181825'
      hc attr theme.tab_title_color '#cdd6f4'

      hc set frame_bg_transparent on
      hc set frame_padding        0
      hc set frame_border_width   0

      hc unlock

      kitty /data/$USER/
    '';
in
{
  home.packages = with pkgs; [
    herbstluftwm
    feh
    xorg.xwininfo
  ];

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
        "class_g = 'Rofi'",
        "class_g = 'GLava'",
        "class_g = '_HERBST_FRAME'",
      ];
    '';
  };

  home.file.".config/sx/sxrc" = {
    executable = true;
    text = ''
      ${pkgs.feh}/bin/feh --bg-fill ${../../config/wallpaper.png} &
      ${pkgs.picom}/bin/picom &
      ${pkgs.herbstluftwm}/bin/herbstluftwm -c ${autostart}
    '';
  };
}

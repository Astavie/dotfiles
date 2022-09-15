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

      hc keybind $Mod-Shift-s split bottom 0.5
      hc keybind $Mod-s       split right  0.5
      hc keybind $Mod-Shift-e split explode

      resizestep=0.02
      hc keybind $Mod-Control-h resize left +$resizestep
      hc keybind $Mod-Control-j resize down +$resizestep
      hc keybind $Mod-Control-k resize up +$resizestep
      hc keybind $Mod-Control-l resize right +$resizestep

      hc keybind $Mod-r remove
      hc keybind $Mod-f floating toggle
      hc keybind $Mod-p pseudotile toggle

      hc keybind $Mod-BackSpace   cycle_monitor
      hc keybind $Mod-Tab         cycle_all +1
      hc keybind $Mod-Shift-Tab   cycle_all -1
      hc keybind $Mod-c cycle
      hc keybind $Mod-i jumpto urgent

      hc mouseunbind --all
      hc mousebind $Mod-Button1 move
      hc mousebind $Mod-Button2 zoom
      hc mousebind $Mod-Button3 resize

      hc unrule -F
      hc rule focus=on
      hc rule floatplacement=smart
      hc rule windowtype~'_NET_WM_WINDOW_TYPE_(DIALOG|UTILITY|SPLASH)' floating=on
      hc rule windowtype='_NET_WM_WINDOW_TYPE_DIALOG' focus=on
      hc rule windowtype~'_NET_WM_WINDOW_TYPE_(NOTIFICATION|DOCK|DESKTOP)' manage=off
      hc rule fixedsize floating=on

      hc set tree_style '╾│ ├└╼─┐'
      hc set window_gap 12
      hc set frame_padding 0
      hc set smart_window_surroundings 0
      hc set smart_frame_surroundings 1
      hc set mouse_recenter_gap 0

      hc attr theme.tiling.reset 1
      hc attr theme.floating.reset 1
      hc set frame_border_active_color '#222222'
      hc set frame_border_normal_color '#101010'
      hc set frame_bg_normal_color '#565656'
      hc set frame_bg_active_color '#345F0C'
      hc set frame_border_width 1
      hc set always_show_frame 1
      hc set frame_bg_transparent 1
      hc set frame_transparent_width 5
      hc set frame_gap 4

      hc attr theme.active.color '#9fbc00'
      hc attr theme.normal.color '#454545'
      hc attr theme.urgent.color orange
      hc attr theme.inner_width 1
      hc attr theme.inner_color black
      hc attr theme.border_width 3
      hc attr theme.floating.border_width 4
      hc attr theme.floating.outer_width 1
      hc attr theme.floating.outer_color black
      hc attr theme.active.inner_color '#3E4A00'
      hc attr theme.active.outer_color '#3E4A00'
      hc attr theme.background_color '#141414'

      hc unlock

      kitty /data/$USER/
    '';
in
{
  home.packages = with pkgs; [
    herbstluftwm
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

  home.file.".config/sx/sxrc" = {
    executable = true;
    text = ''
      ${pkgs.feh}/bin/feh --bg-fill ${../../config/wallpaperlight.png} &
      ${pkgs.picom}/bin/picom &
      ${pkgs.herbstluftwm}/bin/herbstluftwm -c ${autostart}
    '';
  };
}

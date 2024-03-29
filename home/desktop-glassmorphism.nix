{ pkgs, ... }:

{
  home.packages = with pkgs; [
    hyprpaper                # wallpaper
    tofi                     # app launcher
    grim slurp wl-clipboard  # screenshots
    wf-recorder vlc          # recording
                             # notifications
    opentabletdriver         # wacom

    # fonts
    (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
  ];

  fonts.fontconfig.enable = true;
  home.file.".local/share/fonts/misc/cozette.bdf".source = ../res/cozette.bdf;
  home.file.".local/share/fonts/misc/cozette_hidpi.bdf".source = ../res/cozette_hidpi.bdf;
  home.file.".local/share/fonts/misc/spleen-5x8.bdf".source = ../res/spleen-5x8.bdf;
  home.file.".local/share/fonts/misc/spleen-6x12.bdf".source = ../res/spleen-6x12.bdf;
  home.file.".local/share/fonts/misc/spleen-8x16.bdf".source = ../res/spleen-8x16.bdf;
  home.file.".local/share/fonts/misc/spleen-12x24.bdf".source = ../res/spleen-12x24.bdf;
  home.file.".local/share/fonts/misc/spleen-16x32.bdf".source = ../res/spleen-16x32.bdf;
  home.file.".local/share/fonts/misc/spleen-32x64.bdf".source = ../res/spleen-32x64.bdf;

  # custom theme
  home.file.".config/discocss/custom.css".source = ../res/glassmorphism/discord.css;

  # catppuccin theme
  home.file.".themes".source = ../res/catppuccin/gtk;
  home.file.".local/share/mc/skins/theme.ini".source = ../res/catppuccin/mc.ini;
  home.file.".config/helix/themes/catppuccin.toml".source = ../res/catppuccin/helix.toml;
  programs.helix.settings.theme = "catppuccin";

  # hyprpaper config
  home.file.".config/hypr/hyprpaper.conf".text = ''
    preload = ${../res/glassmorphism/wallpaper.png}
    wallpaper = ,${../res/glassmorphism/wallpaper.png}
  '';

  # hyprland config
  home.file.".config/hypr/hyprland.conf".text = ''
    monitor=HDMI-A-1, 1920x1080@60, 2560x0, 1
    monitor=DP-1, 3840x2160@144, 0x0, 1.5

    monitor=HDMI-A-1, transform, 1

    # unscale XWayland
    xwayland {
      force_zero_scaling = true
    }

    env = XCURSOR_SIZE,24

    exec-once = hyprpaper
    exec-once = systemctl --user start easyeffects.service

    input {
      follow_mouse = 2
    }

    general {
      border_size = 0
    }

    decoration {
      rounding = 8

      blur {
        enabled = true
        size = 12
        passes = 3
      }

      drop_shadow = true
      shadow_range = 16
      shadow_render_power = 2
      col.shadow = 0x1a000000
    }

    animation=windows,1,1,default,popin
    animation=workspaces,1,2,default,slide
    animation=fade,0,1,default

    layerrule = blur,waybar
    layerrule = blur,launcher

    windowrulev2 = opacity 0.0 override 0.0 override,class:^(xwaylandvideobridge)$
    windowrulev2 = noanim,class:^(xwaylandvideobridge)$
    windowrulev2 = nofocus,class:^(xwaylandvideobridge)$
    windowrulev2 = noinitialfocus,class:^(xwaylandvideobridge)$

    $mod = SUPER

    bind = $mod, return, exec, fish -c 'alacritty --working-directory $GLOBAL_PWD'
    bind = $mod, space, exec, exec $(tofi-drun --config ${../res/glassmorphism/tofi})
    bind = $mod, Q, killactive,
    bind = $mod SHIFT, Q, exit,
    bind = $mod, P, togglefloating,
    bind = $mod, F, fakefullscreen

    bind = $mod, U, exec, [float] alacritty -e bash -lic "uup /data/astavie/dotfiles/ ; read -p Done!"
    bind = $mod SHIFT, U, exec, [float] alacritty -e bash -lic "sup /data/astavie/dotfiles/ ; read -p Done!"

    bind = $mod SHIFT, P, exec, grim -g "$(slurp)" -t png - | wl-copy  -t image/png
    bind = $mod SHIFT, R, exec, ${pkgs.writeShellScript "record.sh" ''
      pkill --euid "$USER" --signal SIGINT wf-recorder && exit
      Coords=$(slurp) || exit
      rm -f "/home/$USER/new.mp4"
      wf-recorder -g "$Coords" -f "/home/$USER/new.mp4" || exit
      vlc "/home/$USER/new.mp4"
    ''}
    bind = $mod SHIFT, A, exec, ${pkgs.writeShellScript "audio.sh" ''
      pkill --euid "$USER" --signal SIGINT pw-cat && exit
      rm -f "/home/$USER/new.wav"
      pw-cat --record --target=85 "/home/$USER/new.wav"
      vlc "/home/$USER/new.wav"
    ''}

    bind = $mod, H, movefocus, l
    bind = $mod, J, movefocus, d
    bind = $mod, K, movefocus, u
    bind = $mod, L, movefocus, r

    bind = $mod SHIFT, H, movewindow, l
    bind = $mod SHIFT, J, movewindow, d
    bind = $mod SHIFT, K, movewindow, u
    bind = $mod SHIFT, L, movewindow, r

    bind = $mod, comma, workspace, e-1
    bind = $mod, period, workspace, e+1
    bind = $mod SHIFT, comma, movetoworkspace, e-1
    bind = $mod SHIFT, period, movetoworkspace, e+1
    bind = $mod, N, movetoworkspace, empty

    bind = $mod, R, swapactiveworkspaces, current +1
    bind = $mod, O, movewindow, mon:+1

    bindm = $mod, mouse:272, movewindow
    bindm = $mod, mouse:273, resizewindow
  '';

  # terminal emulator
  programs.alacritty = {
    enable = true;
    settings = {
      window.opacity = 0.66;
      window.dynamic_padding = true;
      window.padding.x = 4;
      window.padding.y = 4;

      # font.normal.family = "Ark Pixel 16px Monospaced latin";
      # font.offset.x = 1;
      # font.offset.y = 6;
      # font.glyph_offset.x = 1;
      # font.glyph_offset.y = 6;

      font.normal.family = "Spleen";
      font.offset.x = 1;
      font.size = 8;

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
      };
    };
  };

  # cursor
  home.pointerCursor = 
    let 
      getFrom = url: hash: name: {
          gtk.enable = true;
          x11.enable = true;
          name = name;
          size = 24;
          package = 
            pkgs.runCommand "moveUp" {} ''
              mkdir -p $out/share/icons
              ln -s ${pkgs.fetchzip {
                url = url;
                hash = hash;
              }} $out/share/icons/${name}
          '';
        };
    in
      getFrom 
        "https://github.com/ganwell/dmz-cursors/releases/download/v1.0/dmz-black.tar.xz"
        "sha256-mf60uHFEjWGTk1QZ4AA54g3yJUGipF2ZLNQK7oUGQ4I="
        "DMZ-Black";
}

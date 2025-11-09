{ pkgs, ... }:

{
  home.packages = with pkgs; [
    nerd-fonts.caskaydia-mono
    cascadia-code
  ];

  # hyprland settings
  wayland.windowManager.hyprland.settings = {
    general.border_size = 0;

    decoration = {
      blur = {
        enabled = true;
        size = 8;
        passes = 3;
      };

      shadow = {
        enabled = true;
        range = 15;
        render_power = 2;
        color = "0x1a000000";
      };
    };

    animation = [
      "windows,1,1,default,popin"
      "workspaces,1,2,default,slide"
      "fade,0,1,default"
    ];

    layerrule = [
      "blur,waybar"
      "blur,launcher"
    ];

    "plugin:hyprfocus" = {
      enabled = true;
      animate_floating = true;
      animate_workspacechange = true;
      focus_animation = "flash";

      bezier = [
        "realsmooth, 0.28, 0.29, 0.69, 1.08"
      ];
      
      flash = {
        flash_opacity = 0.93;
        in_bezier = "realsmooth";
        in_speed = 0.5;
        out_bezier = "realsmooth";
        out_speed = 3;
      };
    };
  };

  home.file.".config/tofi/config".source = ../res/glassmorphism/tofi;
  home.file.".config/waybar/style.css".source = ../res/catppuccin/waybar.css;
  home.file.".config/discocss/custom.css".source = ../res/catppuccin/discord.css;
  home.file.".config/vesktop/themes/catppuccin.css".source = ../res/catppuccin/discord.css;

  # bitmap fonts
  fonts.fontconfig.enable = true;
  home.file.".local/share/fonts/misc/cozette.bdf".source = ../res/cozette.bdf;
  home.file.".local/share/fonts/misc/cozette_hidpi.bdf".source = ../res/cozette_hidpi.bdf;
  home.file.".local/share/fonts/misc/spleen-5x8.bdf".source = ../res/spleen-5x8.bdf;
  home.file.".local/share/fonts/misc/spleen-6x12.bdf".source = ../res/spleen-6x12.bdf;
  home.file.".local/share/fonts/misc/spleen-8x16.bdf".source = ../res/spleen-8x16.bdf;
  home.file.".local/share/fonts/misc/spleen-12x24.bdf".source = ../res/spleen-12x24.bdf;
  home.file.".local/share/fonts/misc/spleen-16x32.bdf".source = ../res/spleen-16x32.bdf;
  home.file.".local/share/fonts/misc/spleen-32x64.bdf".source = ../res/spleen-32x64.bdf;

  # theme
  programs.helix.settings.theme = "catppuccin";
  home.file.".config/helix/themes/catppuccin.toml".source = ../res/catppuccin/helix.toml;
  home.file.".config/hypr/hyprpaper.conf".text = ''
    preload = ${../res/glassmorphism/neoncity.jpg}
    wallpaper = ,${../res/glassmorphism/neoncity.jpg}
  '';

  # terminal emulator
  programs.wezterm.extraConfig = ''
    local config = wezterm.config_builder()

    config.dpi = 384.0

    config.font = wezterm.font 'Cascadia Code'
    config.font_size = 10.0

    config.force_reverse_video_cursor = true
    config.force_reverse_video_selection = true
    config.check_for_updates = false

    config.colors = {
      foreground = '#cdd6f4',
      background = '#1e1e2e',

      cursor_border = '#cdd6f4',

      ansi = {
        '#1e1e2e',
        '#eba0ac',
        '#a6e3a1',
        '#f9e2af',
        '#89b4fa',
        '#f5c2e7',
        '#94e2d5',
        '#bac2de',
      },
      brights = {
        '#585b70',
        '#eba0ac',
        '#a6e3a1',
        '#f9e2af',
        '#89b4fa',
        '#f5c2e7',
        '#94e2d5',
        '#a6adc8',
      },
    }

    config.enable_tab_bar = false
    config.window_background_opacity = 0.6

    return config
  '';

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

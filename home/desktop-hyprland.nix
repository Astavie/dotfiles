{ pkgs, inputs, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  home.packages = with pkgs; [
    hyprpaper                # wallpaper
    tofi                     # app launcher
    grim slurp wl-clipboard  # screenshots
    wf-recorder vlc          # recording
    waybar
    kando
  ];

  programs.wezterm = {
    enable = true;
    package = inputs.wezterm.packages.${system}.default.overrideAttrs (final: prev: {
      patches = [(
        pkgs.fetchpatch {
          url = "https://patch-diff.githubusercontent.com/raw/wez/wezterm/pull/4093.patch";
          hash = "sha256-kk1OuP8Vh6gs9+vk8CNcrRMXqyCvU2qs41OG9uJAAFk=";
        }
      )];
    });
  };

  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${system}.hyprland;

    settings = {
      monitor = ["DP-1, 3840x2160@60, 0x0, 1.5"];
      input.follow_mouse = 2;
      xwayland.force_zero_scaling = true;
      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
        "GDK_SCALE,1.5"
      ];

      exec-once = [
        "hyprpaper"
        "systemctl --user start easyeffects.service"
        "kando --ozone-platform-hint=auto"
        "waybar"
      ];

      "$mod" = "SUPER";
      "$term" = "wezterm";

      bind = [
        # window creation / destruction
        "CTRL SHIFT, Super_R, global, kando:run"
        "$mod, return, exec, $term"
        "$mod, Q, killactive"
        "$mod SHIFT, Q, exit"

        "$mod, P, togglefloating"
        "$mod, P, pin"

        # TODO: fix these
        "$mod, U, exec, [float] $term -e bash -lic \"uup /data/astavie/dotfiles/ ; read -p Done!\""
        "$mod SHIFT, U, exec, [float] $term -e bash -lic \"sup /data/astavie/dotfiles/ ; read -p Done!\""

        # screenshot / recording
        "$mod SHIFT, P, exec, grim -g \"$(slurp)\" -t png - | wl-copy  -t image/png"
        "$mod SHIFT, R, exec, ${pkgs.writeShellScript "record.sh" ''
          pkill --euid "$USER" --signal SIGINT wf-recorder && exit
          Coords=$(slurp) || exit
          rm -f "/home/$USER/new.mp4"
          wf-recorder -g "$Coords" -f "/home/$USER/new.mp4" || exit
          vlc "/home/$USER/new.mp4"
        ''}"
        "$mod SHIFT, A, exec, ${pkgs.writeShellScript "audio.sh" ''
          pkill --euid "$USER" --signal SIGINT pw-cat && exit
          rm -f "/home/$USER/new.wav"
          pw-cat --record --target=85 "/home/$USER/new.wav"
          vlc "/home/$USER/new.wav"
        ''}"

        # window movement
        "$mod, H, movefocus, l"
        "$mod, J, movefocus, d"
        "$mod, K, movefocus, u"
        "$mod, L, movefocus, r"

        "$mod SHIFT, H, movewindow, l"
        "$mod SHIFT, J, movewindow, d"
        "$mod SHIFT, K, movewindow, u"
        "$mod SHIFT, L, movewindow, r"

        "$mod, comma, workspace, e-1"
        "$mod, period, workspace, e+1"
        "$mod SHIFT, comma, movetoworkspace, e-1"
        "$mod SHIFT, period, movetoworkspace, e+1"
        "$mod, N, workspace, empty"
        "$mod SHIFT, N, movetoworkspace, empty"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      windowrule = [
        "noblur, kando"
        "opaque, kando"
        "size 100% 100%, kando"
        "center, kando"
        "noborder, kando"
        "noanim, kando"
        "float, kando"
        "pin, kando"
      ];

    };

    plugins = [
      # inputs.hyprland-plugins.packages.${system}.hyprbars
      # inputs.hy3.packages.${system}.hy3
      inputs.hyprfocus.packages.${system}.hyprfocus
    ];
  };

  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 24;
        output = ["DP-1"];
        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "hyprland/window" ];
        modules-right = [ "tray" "wireplumber" "memory" "cpu" "temperature" "clock" "custom/power" ];     
        "hyprland/workspaces" = {
          format = "{id} {windows} ";
          format-window-separator = " ";
          window-rewrite-default = "";
          window-rewrite = {
            "title<.*youtube.*>" = "󰗃";
            "title<.*github.*>" = "󰊤";
            "title<.*reddit.*>" = "󰑍";
            "zen" = "";
            "title<hx .*>" = "󰅩";
            "steam" = "";
            "vesktop" = "";
            "vlc" = "󰕼";
            "kdenlive" = "";
            "gimp" = "";
            "obs" = "󱜠";
            "prismlauncher" = "󰍳";
            "title<Minecraft .*>" = "󰍳";
          };
        };
        memory = {
          format = " {icon}";
          format-icons = ["   " "▏  " "▎  " "▍  " "▌  " "▋  " "▊  " "▉  " "█  " "█▏ " "█▍ " "█▌ " "█▋ " "█▊ " "█▉ " "██ " "██▏" "██▎" "██▍" "██▌"];
          tooltip-format = "{used:0.1f}GiB / {total:0.1f}GiB";
        };
        cpu = {
          format = " {icon}";
          format-icons = ["   " "▏  " "▎  " "▍  " "▌  " "▋  " "▊  " "▉  " "█  " "█▏ " "█▍ " "█▌ " "█▋ " "█▊ " "█▉ " "██ " "██▏" "██▎" "██▍" "██▌"];
        };
        temperature = {
          format = "{icon}";
          format-icons = ["   " " ▏  " " ▎  " "  ▍  " " ▌  " " ▋  " " ▊  " " ▉  " " █  " " █▏ " " █▍ " " █▌ " " █▋ " " █▊ " " █▉ " " ██ " " ██▏" " ██▎" " ██▍" " ██▌"];
        };
        wireplumber = {
          format = "{icon}";
          format-icons = ["󰸈    " "󰕿 ▏  " "󰕿 ▎  " "󰕿 ▍  " "󰕿 ▌  " "󰕿 ▋  " "󰕿 ▊  " "󰕿 ▉  " "󰕿 █  " "󰕿 █▏ " "󰖀 █▍ " "󰖀 █▌ " "󰖀 █▋ " "󰖀 █▊ " "󰖀 █▉ " "󰕾 ██ " "󰕾 ██▏" "󰕾 ██▎" "󰕾 ██▍" "󰕾 ██▌"];
          format-muted = "󰸈    ";
          tooltip = true;
          tooltip-format = "{volume}%";
          scroll-step = 5;
          on-click = "pavucontrol";
        };
        clock = {
          format = "{:%H:%M}";
          format-alt = "{:%A, %B %d, %Y (%R)}";
          tooltip-format = "<tt><small>{calendar}</small></tt>"; 
          calendar = {
            mode = "month";
            mode-mon-col = 3;
            weeks-pos = "right";
            on-scroll = 1;
            format = {
              months = "<span color='#ffead3'><b>{}</b></span>";
              days = "<span color='#ecc6d9'><b>{}</b></span>";
              weeks = "<span color='#99ffdd'><b>W{}</b></span>";
              weekdays = "<span color='#ffcc66'><b>{}</b></span>";
              today = "<span color='#ff6699'><b><u>{}</u></b></span>";
            };
          };
          actions = {
            on-click-right = "mode";
            on-click-forward = "tz_up";
            on-click-backward = "tz_down";
            on-scroll-up = "shift_up";
            on-scroll-down = "shift_down";
          };
        };
        "custom/power" = {
          format = " 󰤄 ";
          tooltip = false;
          on-click = "systemctl suspend";
        };
      };
    };
  };
}

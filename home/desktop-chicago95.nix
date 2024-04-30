{ pkgs, ... }:

let
  chicago95 = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "chicago95";
    version = "3.0.1";

    buildInputs = [pkgs.gdk-pixbuf pkgs.xfce.xfce4-panel-profiles];

    src = pkgs.fetchFromGitHub {
      owner = "grassmunk";
      repo = "Chicago95";
      rev = "v${version}";
      hash = "sha256-EHcDIct2VeTsjbQWnKB2kwSFNb97dxuydAu+i/VquBA=";
    };

    # the Makefile is just for maintainers
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/{themes,icons,sounds}

      cp -r Theme/Chicago95 $out/share/themes
      cp -r Icons/* $out/share/icons
      cp -r Cursors/* $out/share/icons
      cp -r sounds/Chicago95 $out/share/sounds

      cp -r Fonts/bitmap/cronyx-cyrillic $out/share/fonts
      cp -r Fonts/vga_font $out/share/fonts/truetype

      runHook postInstall
    '';
  };
in
{
  home.packages = with pkgs; [
    chicago95
    xfce.thunar
    scrot xclip peek
    xorg.xkill
  ];

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

  # terminal emulator
  programs.alacritty = {
    enable = true;
    settings = {
      window.dynamic_padding = true;
      window.padding.x = 4;
      window.padding.y = 4;

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

}

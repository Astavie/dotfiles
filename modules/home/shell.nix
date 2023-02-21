{ pkgs, config, ... }:

{
  programs.fish = {
    enable = true;
    functions = {
      s = ''
        kitty +kitten ssh $argv
      '';
      fish_prompt = ''
        if test "$PWD" != "$PWD_PREV"
          echo

          set -l left    "$PWD"
          set -l right   (whoami)@(prompt_hostname)
          set -l padding (math $COLUMNS - (string length -- "$left$right"))

          set_color -b blue
          set_color black
          echo (printf "%s%-"$padding"s%s" "$left" " " "$right")
          set_color normal

          ls -AC -w $COLUMNS --group-directories-first -F --color
        end
        
        echo '> '
        set -g PWD_PREV $PWD
      '';
    };
  };

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;
  programs.autojump.enable = true;

  backup.directories = [
    "autojump/.local/share/autojump"
    "direnv/.local/share/direnv/allow"
    "fish/.local/share/fish"
  ];

  # Helix
  programs.helix.enable = true;
  programs.helix.package = pkgs.unstable.helix;
  programs.helix.settings.theme = "catppuccin_mocha";
  home.sessionVariables.EDITOR = "${config.programs.helix.package}/bin/hx";

  # midnight commander
  home.packages = with pkgs; [ mc ];
  home.file.".local/share/mc/skins/theme.ini".source = ../../config/mc.ini;
  home.file.".config/mc/ini".text = ''
    [Midnight-Commander]
    skin=theme
    use_internal_edit=false
  '';

}
